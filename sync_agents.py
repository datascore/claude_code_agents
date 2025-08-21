#!/usr/bin/env python3
"""
Claude Agent Prompts Sync Helper
Python module for synchronizing agent prompts from GitHub
"""

import os
import sys
import json
import subprocess
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class AgentSync:
    """Manages synchronization of Claude agent prompts from GitHub."""
    
    def __init__(self, repo_url: Optional[str] = None, agents_dir: Optional[str] = None):
        """
        Initialize the AgentSync manager.
        
        Args:
            repo_url: GitHub repository URL (or set AGENT_REPO_URL env var)
            agents_dir: Local directory for agents (default: ~/agents)
        """
        self.repo_url = repo_url or os.environ.get('AGENT_REPO_URL', '')
        self.agents_dir = Path(agents_dir or os.environ.get('AGENTS_DIR', Path.home() / 'agents'))
        self.backup_dir = self.agents_dir / '.backups'
        self.log_file = self.agents_dir / '.sync.log'
        
    def is_initialized(self) -> bool:
        """Check if the agents directory is initialized as a git repo."""
        return (self.agents_dir / '.git').exists()
    
    def initialize(self) -> bool:
        """
        Initialize the agents repository.
        
        Returns:
            True if successful, False otherwise
        """
        if not self.repo_url:
            print("ERROR: Repository URL not set. Set AGENT_REPO_URL environment variable.")
            return False
        
        if not self.agents_dir.exists():
            self.agents_dir.mkdir(parents=True)
        
        if not self.is_initialized():
            try:
                # Clone the repository
                result = subprocess.run(
                    ['git', 'clone', self.repo_url, str(self.agents_dir)],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    self._log("Repository cloned successfully")
                    return True
                else:
                    print(f"Failed to clone repository: {result.stderr}")
                    return False
            except Exception as e:
                print(f"Error cloning repository: {e}")
                return False
        return True
    
    def check_for_updates(self) -> bool:
        """
        Check if there are updates available from the remote repository.
        
        Returns:
            True if updates are available, False otherwise
        """
        if not self.is_initialized():
            return False
        
        try:
            # Fetch latest changes
            subprocess.run(
                ['git', 'fetch', 'origin'],
                cwd=self.agents_dir,
                capture_output=True
            )
            
            # Check if local is behind remote
            result = subprocess.run(
                ['git', 'rev-list', '--count', 'HEAD..origin/main'],
                cwd=self.agents_dir,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                # Try master branch
                result = subprocess.run(
                    ['git', 'rev-list', '--count', 'HEAD..origin/master'],
                    cwd=self.agents_dir,
                    capture_output=True,
                    text=True
                )
            
            return int(result.stdout.strip()) > 0 if result.returncode == 0 else False
            
        except Exception as e:
            print(f"Error checking for updates: {e}")
            return False
    
    def sync(self, force: bool = False) -> Tuple[bool, List[str]]:
        """
        Synchronize with the remote repository.
        
        Args:
            force: Force sync even if there are local changes
            
        Returns:
            Tuple of (success: bool, changed_files: List[str])
        """
        if not self.is_initialized():
            if not self.initialize():
                return False, []
        
        changed_files = []
        
        try:
            # Check for local changes
            result = subprocess.run(
                ['git', 'status', '--porcelain'],
                cwd=self.agents_dir,
                capture_output=True,
                text=True
            )
            
            if result.stdout.strip():
                if not force:
                    print("Local changes detected. Use force=True to override or backup first.")
                    return False, []
                else:
                    # Backup and stash local changes
                    self.backup()
                    subprocess.run(
                        ['git', 'stash', 'push', '-m', f'Auto-stash {datetime.now()}'],
                        cwd=self.agents_dir
                    )
            
            # Get list of files before pull
            before_result = subprocess.run(
                ['git', 'ls-tree', '-r', 'HEAD', '--name-only'],
                cwd=self.agents_dir,
                capture_output=True,
                text=True
            )
            before_files = set(before_result.stdout.splitlines())
            
            # Pull latest changes
            pull_result = subprocess.run(
                ['git', 'pull', 'origin', 'main'],
                cwd=self.agents_dir,
                capture_output=True,
                text=True
            )
            
            if pull_result.returncode != 0:
                # Try master branch
                pull_result = subprocess.run(
                    ['git', 'pull', 'origin', 'master'],
                    cwd=self.agents_dir,
                    capture_output=True,
                    text=True
                )
            
            if pull_result.returncode == 0:
                # Get list of files after pull
                after_result = subprocess.run(
                    ['git', 'ls-tree', '-r', 'HEAD', '--name-only'],
                    cwd=self.agents_dir,
                    capture_output=True,
                    text=True
                )
                after_files = set(after_result.stdout.splitlines())
                
                # Find changed files
                changed_files = list(after_files.symmetric_difference(before_files))
                
                self._log(f"Synced successfully. {len(changed_files)} files changed.")
                return True, changed_files
            else:
                print(f"Failed to pull updates: {pull_result.stderr}")
                return False, []
                
        except Exception as e:
            print(f"Error during sync: {e}")
            return False, []
    
    def backup(self) -> Optional[Path]:
        """
        Create a backup of current agent files.
        
        Returns:
            Path to backup directory if successful, None otherwise
        """
        try:
            self.backup_dir.mkdir(exist_ok=True)
            
            # Create timestamped backup directory
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_path = self.backup_dir / f'backup_{timestamp}'
            backup_path.mkdir()
            
            # Copy all .md files
            for md_file in self.agents_dir.glob('*.md'):
                shutil.copy2(md_file, backup_path)
            
            # Keep only last 5 backups
            backups = sorted(self.backup_dir.glob('backup_*'))
            for old_backup in backups[:-5]:
                shutil.rmtree(old_backup)
            
            self._log(f"Backup created: {backup_path}")
            return backup_path
            
        except Exception as e:
            print(f"Error creating backup: {e}")
            return None
    
    def list_agents(self) -> List[Dict[str, str]]:
        """
        List all available agent prompts.
        
        Returns:
            List of dictionaries with agent information
        """
        agents = []
        
        for agent_file in sorted(self.agents_dir.glob('*.md')):
            # Read first few lines to get agent role
            try:
                with open(agent_file, 'r') as f:
                    lines = f.readlines()[:10]
                    role = None
                    for line in lines:
                        if line.strip().startswith('## Role'):
                            # Get the next non-empty line
                            idx = lines.index(line) + 1
                            while idx < len(lines):
                                next_line = lines[idx].strip()
                                if next_line and not next_line.startswith('#'):
                                    role = next_line[:100] + '...' if len(next_line) > 100 else next_line
                                    break
                                idx += 1
                            break
                    
                    agents.append({
                        'name': agent_file.stem,
                        'file': str(agent_file),
                        'size': agent_file.stat().st_size,
                        'modified': datetime.fromtimestamp(agent_file.stat().st_mtime).isoformat(),
                        'role': role or 'No description available'
                    })
            except Exception as e:
                print(f"Error reading {agent_file}: {e}")
        
        return agents
    
    def get_agent(self, agent_name: str) -> Optional[str]:
        """
        Get the content of a specific agent prompt.
        
        Args:
            agent_name: Name of the agent (without .md extension)
            
        Returns:
            Agent prompt content or None if not found
        """
        agent_file = self.agents_dir / f'{agent_name}.md'
        
        if not agent_file.exists():
            # Try with .md extension if provided
            agent_file = self.agents_dir / agent_name
        
        if agent_file.exists():
            try:
                with open(agent_file, 'r') as f:
                    return f.read()
            except Exception as e:
                print(f"Error reading agent file: {e}")
        
        return None
    
    def get_status(self) -> Dict:
        """
        Get the current repository status.
        
        Returns:
            Dictionary with status information
        """
        status = {
            'initialized': self.is_initialized(),
            'agents_dir': str(self.agents_dir),
            'repo_url': self.repo_url,
            'last_sync': None,
            'total_agents': 0,
            'has_updates': False,
            'local_changes': []
        }
        
        if self.is_initialized():
            # Get agent count
            status['total_agents'] = len(list(self.agents_dir.glob('*.md')))
            
            # Get last sync time from log
            if self.log_file.exists():
                try:
                    with open(self.log_file, 'r') as f:
                        lines = f.readlines()
                        if lines:
                            last_line = lines[-1]
                            status['last_sync'] = last_line.split(' - ')[0]
                except:
                    pass
            
            # Check for updates
            status['has_updates'] = self.check_for_updates()
            
            # Check for local changes
            try:
                result = subprocess.run(
                    ['git', 'status', '--porcelain'],
                    cwd=self.agents_dir,
                    capture_output=True,
                    text=True
                )
                if result.stdout:
                    status['local_changes'] = result.stdout.strip().split('\n')
            except:
                pass
        
        return status
    
    def _log(self, message: str):
        """Write a log message."""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"{timestamp} - {message}\n"
        
        try:
            with open(self.log_file, 'a') as f:
                f.write(log_entry)
        except:
            pass


# CLI interface
def main():
    """Command-line interface for agent sync."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Claude Agent Prompts Sync Tool')
    parser.add_argument('--sync', action='store_true', help='Sync with remote repository')
    parser.add_argument('--status', action='store_true', help='Show repository status')
    parser.add_argument('--list', action='store_true', help='List available agents')
    parser.add_argument('--get', metavar='AGENT', help='Get specific agent content')
    parser.add_argument('--backup', action='store_true', help='Create backup')
    parser.add_argument('--force', action='store_true', help='Force sync even with local changes')
    parser.add_argument('--repo', metavar='URL', help='Set repository URL')
    parser.add_argument('--dir', metavar='PATH', help='Set agents directory')
    
    args = parser.parse_args()
    
    # Initialize sync manager
    sync = AgentSync(repo_url=args.repo, agents_dir=args.dir)
    
    if args.sync:
        success, changed = sync.sync(force=args.force)
        if success:
            print(f"✓ Sync successful. {len(changed)} files changed.")
            if changed:
                print("Changed files:")
                for f in changed:
                    print(f"  - {f}")
        else:
            print("✗ Sync failed.")
            sys.exit(1)
    
    elif args.status:
        status = sync.get_status()
        print("=== Agent Repository Status ===")
        print(f"Initialized: {status['initialized']}")
        print(f"Directory: {status['agents_dir']}")
        print(f"Repository: {status['repo_url'] or 'Not configured'}")
        print(f"Total agents: {status['total_agents']}")
        print(f"Last sync: {status['last_sync'] or 'Never'}")
        print(f"Updates available: {status['has_updates']}")
        if status['local_changes']:
            print(f"Local changes: {len(status['local_changes'])} files")
    
    elif args.list:
        agents = sync.list_agents()
        if agents:
            print("=== Available Agents ===")
            for agent in agents:
                print(f"\n{agent['name']}")
                print(f"  Role: {agent['role']}")
                print(f"  Modified: {agent['modified']}")
                print(f"  Size: {agent['size']} bytes")
        else:
            print("No agents found.")
    
    elif args.get:
        content = sync.get_agent(args.get)
        if content:
            print(content)
        else:
            print(f"Agent '{args.get}' not found.")
            sys.exit(1)
    
    elif args.backup:
        backup_path = sync.backup()
        if backup_path:
            print(f"✓ Backup created: {backup_path}")
        else:
            print("✗ Backup failed.")
            sys.exit(1)
    
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
