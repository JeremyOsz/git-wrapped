# Git Wrapped 🎵

**Your Year in Code** - A fun bash script to generate beautiful git statistics similar to Spotify Wrapped.

## 📋 Overview

Git Wrapped analyzes your git repository (or multiple repositories) and generates a colorful, emoji-rich summary of your coding activity for a given year. Perfect for reflecting on your coding journey and sharing your year-end stats!

## ✨ Features

- 📈 **Total Commits** - See how many commits you made this year
- 📝 **Lines Changed** - Track lines added, removed, and net change
- 🔀 **Merge Statistics** - Count of merge commits
- 🏆 **Top Committers** - See top contributors with visual bar charts
- 📅 **Most Active Day** - Discover which day of the week you're most productive
- 🔥 **Longest Streak** - Find your longest consecutive days with commits
- 🎨 **Beautiful Output** - Colorful terminal output with emojis and ASCII art
- 🔍 **Multi-Repository Support** - Analyze all git repositories in a directory
- 📊 **Grand Totals** - Aggregate statistics across multiple repositories

## 📦 Requirements

- `bash` (version 4.0 or higher)
- `git` (any modern version)
- Standard Unix tools: `awk`, `sort`, `uniq`, `find`, `date`
- Terminal with color support (most modern terminals)

## 🚀 Installation

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd git-wrapped
   ```

2. Make the script executable:
   ```bash
   chmod +x git-wrapped.sh
   ```

3. (Optional) Add to your PATH or create an alias:
   ```bash
   # Add to PATH
   sudo ln -s $(pwd)/git-wrapped.sh /usr/local/bin/git-wrapped
   
   # Or add alias to ~/.bashrc or ~/.zshrc
   alias git-wrapped="/path/to/git-wrapped.sh"
   ```

## 💻 Usage

### Basic Usage

```bash
# Show stats for current repository and current year
./git-wrapped.sh

# Show stats for a specific year
./git-wrapped.sh 2023

# Show help
./git-wrapped.sh --help
```

### Options

| Option | Description |
|--------|-------------|
| `--all` | Find and summarize all git repositories in directory |
| `--dir DIR` | Directory to search for repositories (default: current directory) |
| `--help`, `-h` | Show help message |
| `YEAR` | Year to analyze (4-digit format, e.g., `2023`) |

### Examples

```bash
# Analyze current repository for 2023
./git-wrapped.sh 2023

# Analyze all repositories in current directory
./git-wrapped.sh --all

# Analyze all repositories in a specific directory
./git-wrapped.sh --all --dir ~/repos

# Combine options - analyze all repos in a directory for a specific year
./git-wrapped.sh --all --dir ~/projects 2023
```

## 📊 Output Description

### Single Repository Mode

When analyzing a single repository, you'll get a detailed report including:

1. **Total Commits** - Total number of commits made in the specified year
2. **Lines Changed** - Breakdown of:
   - Lines added (green)
   - Lines removed (red)
   - Net lines changed (yellow)
3. **Merges** - Number of merge commits
4. **Top Committers** - Top 10 contributors with:
   - Visual bar charts
   - Commit counts
   - Percentages
5. **Most Active Day** - The day of the week with the most commits
6. **Longest Streak** - Longest consecutive days with at least one commit

### All Repositories Mode

When using `--all`, you'll get:

1. **Per-Repository Summary** - For each repository:
   - Repository name and path
   - Commit count
   - Lines added/removed/net change
   - Merge count
   - Top committer (if available)
2. **Grand Totals** - Aggregated statistics across all repositories

## 🎨 Output Preview

The script produces colorful, emoji-enhanced output with ASCII art borders. Colors are used to enhance readability:

- 🟢 Green - Positive metrics (commits, additions)
- 🔴 Red - Deletions, warnings
- 🟡 Yellow - Highlights, net changes
- 🔵 Blue - Paths and metadata
- 🟣 Magenta - Merge statistics
- 🔷 Cyan - Headers and names

## 📝 Notes

- The script analyzes commits made between January 1st and December 31st of the specified year
- Statistics are based on the commit author name (`%an` in git format)
- The script automatically handles errors and gracefully skips repositories that can't be analyzed
- When analyzing multiple repositories, the script searches recursively for all `.git` directories
- Make sure you have read access to the repositories you're analyzing

## ⚠️ Limitations

- The streak calculation may not be perfectly accurate for edge cases (requires dates to be consecutive)
- Large repositories with thousands of commits may take a while to process
- The script requires the repository to have a full git history (not shallow clones)

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is open source and available for personal use.

## 🙏 Credits

Inspired by Spotify Wrapped - bringing that same year-end reflection energy to your code!

---

**Happy Coding! 🎉**

