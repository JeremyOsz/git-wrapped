#!/bin/bash

# Git Wrapped - Your Year in Code
# A fun script to generate git statistics similar to Spotify Wrapped

# Don't exit on errors - we'll handle them manually
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Parse arguments
ALL_REPOS=false
YEAR=""
SEARCH_DIR="."

show_help() {
    echo "Git Wrapped - Your Year in Code"
    echo ""
    echo "Usage: $0 [OPTIONS] [YEAR]"
    echo ""
    echo "Options:"
    echo "  --all              Find and summarize all git repositories in directory"
    echo "  --dir DIR          Directory to search for repositories (default: current directory)"
    echo "  --help, -h         Show this help message"
    echo ""
    echo "Arguments:"
    echo "  YEAR               Year to analyze (default: current year)"
    echo ""
    echo "Examples:"
    echo "  $0                 Show stats for current repository and year"
    echo "  $0 2023            Show stats for 2023"
    echo "  $0 --all           Show summary for all repos in current directory"
    echo "  $0 --all --dir ~/repos  Show summary for all repos in ~/repos"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL_REPOS=true
            shift
            ;;
        --dir)
            SEARCH_DIR="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            ;;
        *)
            if [[ -z "$YEAR" ]] && [[ "$1" =~ ^[0-9]{4}$ ]]; then
                YEAR="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

# Get the current year if not specified
YEAR=${YEAR:-$(date +%Y)}
START_DATE="${YEAR}-01-01"
END_DATE="${YEAR}-12-31"

# Function to calculate stats for a repository
calculate_repo_stats() {
    local repo_path="$1"
    local repo_name="$2"
    local original_dir=$(pwd)
    
    cd "$repo_path" || return 1
    
    # Check if it's a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        cd "$original_dir"
        return 1
    fi
    
    # Get total commits
    local total_commits=$(git log --since="$START_DATE" --until="$END_DATE" --oneline 2>/dev/null | wc -l | tr -d ' ')
    total_commits=${total_commits:-0}
    
    # Get lines changed
    local lines_stats=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=tformat: --numstat 2>/dev/null | \
        awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added: %s removed: %s total: %s", add+0, subs+0, loc+0 }')
    
    local lines_added=$(echo $lines_stats | awk '{print $2}')
    local lines_removed=$(echo $lines_stats | awk '{print $4}')
    local lines_total=$(echo $lines_stats | awk '{print $6}')
    
    lines_added=${lines_added:-0}
    lines_removed=${lines_removed:-0}
    lines_total=${lines_total:-0}
    
    # Get merge commits
    local merge_commits=$(git log --since="$START_DATE" --until="$END_DATE" --merges --oneline 2>/dev/null | wc -l | tr -d ' ')
    merge_commits=${merge_commits:-0}
    
    # Get top committer
    local top_committer=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%an" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    local top_committer_count=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%an" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -1 | awk '{print $1}')
    
    top_committer=${top_committer:-""}
    top_committer_count=${top_committer_count:-0}
    
    # Return to original directory
    cd "$original_dir"
    
    # Output the stats
    echo "$repo_name|$total_commits|$lines_added|$lines_removed|$lines_total|$merge_commits|$top_committer|$top_committer_count"
}

# Function to display full stats for a single repository
display_full_stats() {
    local repo_path="$1"
    
    cd "$repo_path"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository!${NC}"
        exit 1
    fi

    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${WHITE}🎵  GIT WRAPPED ${YEAR}  🎵${NC}  ${BOLD}${CYAN}                                    ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Get total commits in the year
    echo -e "${BOLD}${YELLOW}📊 Calculating your stats...${NC}\n"
    
    local total_commits=$(git log --since="$START_DATE" --until="$END_DATE" --oneline 2>/dev/null | wc -l | tr -d ' ')
    
    # Get lines changed (additions and deletions)
    local lines_stats=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=tformat: --numstat 2>/dev/null | \
        awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added: %s removed: %s total: %s", add, subs, loc }')
    
    local lines_added=$(echo $lines_stats | awk '{print $2}')
    local lines_removed=$(echo $lines_stats | awk '{print $4}')
    local lines_total=$(echo $lines_stats | awk '{print $6}')
    
    # Get number of merge commits
    local merge_commits=$(git log --since="$START_DATE" --until="$END_DATE" --merges --oneline 2>/dev/null | wc -l | tr -d ' ')
    
    # Get top committers
    echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BOLD}${WHITE}📈 TOTAL COMMITS${NC}"
    echo -e "${CYAN}You made ${BOLD}${total_commits}${NC}${CYAN} commits this year!${NC}\n"
    
    echo -e "${BOLD}${WHITE}📝 LINES CHANGED${NC}"
    echo -e "${GREEN}+${lines_added}${NC} ${CYAN}lines added${NC}"
    echo -e "${RED}-${lines_removed}${NC} ${CYAN}lines removed${NC}"
    echo -e "${YELLOW}${lines_total}${NC} ${CYAN}net lines changed${NC}\n"
    
    echo -e "${BOLD}${WHITE}🔀 MERGES${NC}"
    echo -e "${MAGENTA}You merged ${BOLD}${merge_commits}${NC}${MAGENTA} branches this year!${NC}\n"
    
    echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BOLD}${WHITE}🏆 TOP COMMITTERS${NC}\n"
    
    # Get top 10 committers with their commit counts
    git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%an" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -10 | \
        while read count name; do
            # Create a simple bar chart
            if [ "$total_commits" -gt 0 ]; then
                bar_length=$((count * 50 / total_commits))
                if [ $bar_length -eq 0 ] && [ $count -gt 0 ]; then
                    bar_length=1
                fi
                bar=$(printf "%${bar_length}s" | tr ' ' '█')
                
                percentage=$(awk "BEGIN {printf \"%.1f\", ($count/$total_commits)*100}")
                
                echo -e "${CYAN}${name}${NC}"
                echo -e "  ${GREEN}${bar}${NC} ${BOLD}${count}${NC} commits (${percentage}%)"
                echo ""
            fi
        done
    
    echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    # Get most active day of week
    echo -e "${BOLD}${WHITE}📅 MOST ACTIVE DAY${NC}\n"
    local most_active_day=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%a" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    local day_count=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%a" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -1 | awk '{print $1}')
    
    local day_name=""
    case $most_active_day in
        Mon) day_name="Monday" ;;
        Tue) day_name="Tuesday" ;;
        Wed) day_name="Wednesday" ;;
        Thu) day_name="Thursday" ;;
        Fri) day_name="Friday" ;;
        Sat) day_name="Saturday" ;;
        Sun) day_name="Sunday" ;;
        *) day_name=$most_active_day ;;
    esac
    
    if [ -n "$day_name" ] && [ -n "$day_count" ]; then
        echo -e "${YELLOW}${day_name}${NC} ${CYAN}was your most productive day with ${BOLD}${day_count}${NC}${CYAN} commits!${NC}\n"
    fi
    
    # Get longest commit streak (consecutive days with commits)
    echo -e "${BOLD}${WHITE}🔥 LONGEST STREAK${NC}\n"
    local streak=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short 2>/dev/null | \
        sort -u | awk 'BEGIN{prev=""; streak=1; max_streak=1} {
            if(prev != "" && $1 == prev + 1) {
                streak++
                if(streak > max_streak) max_streak = streak
            } else {
                streak = 1
            }
            prev = $1
        } END {print max_streak}')
    
    if [ -z "$streak" ] || [ "$streak" -eq 0 ]; then
        streak=1
    fi
    
    echo -e "${RED}🔥 Your longest commit streak: ${BOLD}${streak}${NC}${RED} days!${NC}\n"
    
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${WHITE}Thanks for coding with us this year! 🎉${NC}  ${BOLD}${CYAN}                    ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to find all git repositories
find_git_repos() {
    local search_dir="$1"
    find "$search_dir" -type d -name ".git" -prune -exec dirname {} \; 2>/dev/null | sort
}

# Function to display summary for all repositories
display_all_repos_summary() {
    local search_dir="$1"
    local original_dir=$(pwd)
    
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${WHITE}🎵  GIT WRAPPED ${YEAR} - ALL REPOSITORIES  🎵${NC}  ${BOLD}${CYAN}            ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BOLD}${YELLOW}🔍 Searching for git repositories in: ${CYAN}${search_dir}${NC}\n"
    
    # Find all git repositories
    local repos=($(find_git_repos "$search_dir"))
    
    if [ ${#repos[@]} -eq 0 ]; then
        echo -e "${RED}No git repositories found!${NC}\n"
        exit 1
    fi
    
    echo -e "${GREEN}Found ${BOLD}${#repos[@]}${NC}${GREEN} git repositories${NC}\n"
    echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    # Arrays to store totals
    local total_commits_all=0
    local total_lines_added_all=0
    local total_lines_removed_all=0
    local total_merges_all=0
    
    # Process each repository
    local repo_num=1
    for repo_path in "${repos[@]}"; do
        local repo_name=$(basename "$repo_path")
        local relative_path=$(realpath --relative-to="$original_dir" "$repo_path" 2>/dev/null || echo "$repo_path")
        
        echo -e "${BOLD}${WHITE}[${repo_num}/${#repos[@]}] ${CYAN}${repo_name}${NC}"
        echo -e "${BLUE}Path: ${relative_path}${NC}\n"
        
        # Calculate stats
        local stats
        stats=$(calculate_repo_stats "$repo_path" "$repo_name")
        local calc_status=$?
        
        if [ $calc_status -eq 0 ] && [ -n "$stats" ]; then
            IFS='|' read -r name commits added removed total merges top_committer top_count <<< "$stats"
            
            # Display summary
            echo -e "  ${GREEN}📈 Commits:${NC} ${BOLD}${commits}${NC}"
            echo -e "  ${GREEN}➕ Lines added:${NC} ${BOLD}${added}${NC}"
            echo -e "  ${RED}➖ Lines removed:${NC} ${BOLD}${removed}${NC}"
            echo -e "  ${YELLOW}📊 Net change:${NC} ${BOLD}${total}${NC}"
            echo -e "  ${MAGENTA}🔀 Merges:${NC} ${BOLD}${merges}${NC}"
            
            if [ -n "$top_committer" ] && [ "$top_committer" != "" ]; then
                echo -e "  ${CYAN}👤 Top committer:${NC} ${BOLD}${top_committer}${NC} (${top_count} commits)"
            fi
            
            # Add to totals
            total_commits_all=$((total_commits_all + commits))
            total_lines_added_all=$((total_lines_added_all + added))
            total_lines_removed_all=$((total_lines_removed_all + removed))
            total_merges_all=$((total_merges_all + merges))
        else
            echo -e "  ${RED}⚠️  Could not calculate stats${NC}"
        fi
        
        echo ""
        repo_num=$((repo_num + 1))
    done
    
    # Display grand totals
    echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "${BOLD}${WHITE}📊 GRAND TOTALS ACROSS ALL REPOSITORIES${NC}\n"
    echo -e "${CYAN}Total commits:${NC} ${BOLD}${total_commits_all}${NC}"
    echo -e "${GREEN}Total lines added:${NC} ${BOLD}${total_lines_added_all}${NC}"
    echo -e "${RED}Total lines removed:${NC} ${BOLD}${total_lines_removed_all}${NC}"
    echo -e "${YELLOW}Net lines changed:${NC} ${BOLD}$((total_lines_added_all - total_lines_removed_all))${NC}"
    echo -e "${MAGENTA}Total merges:${NC} ${BOLD}${total_merges_all}${NC}\n"
    
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${WHITE}Thanks for coding with us this year! 🎉${NC}  ${BOLD}${CYAN}                    ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    cd "$original_dir"
}

# Main execution
if [ "$ALL_REPOS" = true ]; then
    display_all_repos_summary "$SEARCH_DIR"
else
    display_full_stats "."
fi
