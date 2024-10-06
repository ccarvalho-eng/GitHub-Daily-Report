#!/bin/bash

# Check if the required environment variables are set
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_USER or GITHUB_TOKEN environment variables are not set."
  exit 1
fi

# Today's date in ISO 8601 format
TODAY=$(date -u +"%Y-%m-%dT00:00:00Z")

# Function to check if a closed PR was merged
check_merged_status() {
  pr_url="$1"
  # Fetch the PR details
  pr_details=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$pr_url")
  merged_status=$(echo "$pr_details" | jq -r '.merged // empty')

  if [ "$merged_status" == "true" ]; then
    echo "Merged"
  else
    echo "Closed"
  fi
}

# Function to check the review status of a PR
check_review_status() {
  pr_url="$1"
  # Fetch the PR reviews
  reviews=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$pr_url/reviews")
  review_status=$(echo "$reviews" | jq -r '.[].state // empty' | sort -u)

  if [ -z "$review_status" ]; then
    echo "Review Required"
  else
    echo "$review_status"
  fi
}

# Function to fetch today's pull requests
fetch_todays_prs() {
  page=1
  pr_count=0 # Start counting from 0
  echo "Pull Requests"
  echo

  while :; do
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/search/issues?q=type:pr+author:$GITHUB_USER+created:>$TODAY&per_page=100&page=$page")

    # Check if the response contains items
    items_count=$(echo "$response" | jq '.total_count // 0')

    if [ "$items_count" -eq 0 ]; then
      break
    fi

    # Check if the response is valid
    if echo "$response" | jq -e . >/dev/null 2>&1; then
      # Iterate over each PR item
      while read -r pr; do
        title=$(echo "$pr" | jq -r '.title')
        state=$(echo "$pr" | jq -r '.state')
        created_at=$(echo "$pr" | jq -r '.created_at')
        url=$(echo "$pr" | jq -r '.html_url')
        pr_url=$(echo "$pr" | jq -r '.pull_request.url // empty')
        repo_name=$(echo "$url" | awk -F '/' '{print $(NF-3) "/" $(NF-2)}')
        draft=$(echo "$pr" | jq -r '.draft')

        # Check merged status if the PR is closed
        if [ "$state" == "closed" ]; then
          merged_status=$(check_merged_status "$pr_url")
          status_text="($merged_status)"
        else
          if [ "$draft" == "true" ]; then
            status_text="(Draft)"
          else
            review_status=$(check_review_status "$pr_url")
            status_text="($review_status)"
          fi
        fi

        echo "$((pr_count + 1)). Title: $title"
        echo "      a. Repository: $repo_name"
        echo "      b. Status: $state $status_text"
        echo "      c. Created At: $created_at"
        echo "      d. URL: $url"
        echo

        # Increment PR count
        pr_count=$((pr_count + 1))
      done < <(echo "$response" | jq -c '.items[]')
    else
      echo "Error: Unable to parse response."
      echo "$response"
      exit 1
    fi

    page=$((page + 1))
  done

  if [ "$pr_count" -eq 0 ]; then
    echo "No pull requests found for today."
  fi
}

# Function to fetch PRs reviewed by the user
fetch_reviewed_prs() {
  page=1
  review_count=0 # Start counting from 0
  echo "Reviewed Pull Requests"
  echo

  while :; do
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/search/issues?q=type:pr+reviewed-by:$GITHUB_USER+created:>$TODAY&per_page=100&page=$page")

    # Check if the response contains items
    items_count=$(echo "$response" | jq '.total_count // 0')

    if [ "$items_count" -eq 0 ]; then
      break
    fi

    # Check if the response is valid
    if echo "$response" | jq -e . >/dev/null 2>&1; then
      # Iterate over each PR item
      while read -r pr; do
        title=$(echo "$pr" | jq -r '.title')
        state=$(echo "$pr" | jq -r '.state')
        created_at=$(echo "$pr" | jq -r '.created_at')
        url=$(echo "$pr" | jq -r '.html_url')
        pr_url=$(echo "$pr" | jq -r '.pull_request.url // empty')
        repo_name=$(echo "$url" | awk -F '/' '{print $(NF-3) "/" $(NF-2)}')
        draft=$(echo "$pr" | jq -r '.draft')

        # Check merged status if the PR is closed
        if [ "$state" == "closed" ]; then
          merged_status=$(check_merged_status "$pr_url")
          status_text="($merged_status)"
        else
          if [ "$draft" == "true" ]; then
            status_text="(Draft)"
          else
            review_status=$(check_review_status "$pr_url")
            status_text="($review_status)"
          fi
        fi

        echo "$((review_count + 1)). Title: $title"
        echo "      a. Repository: $repo_name"
        echo "      b. Status: $state $status_text"
        echo "      c. Created At: $created_at"
        echo "      d. URL: $url"
        echo

        # Increment review count
        review_count=$((review_count + 1))
      done < <(echo "$response" | jq -c '.items[]')
    else
      echo "Error: Unable to parse response."
      echo "$response"
      exit 1
    fi

    page=$((page + 1))
  done

  if [ "$review_count" -eq 0 ]; then
    echo "No reviewed pull requests found for today."
  fi
}

# Check if jq is installed
if ! command -v jq &>/dev/null; then
  echo "This script requires jq. Please install it."
  exit 1
fi

# Fetch and display today's PRs
fetch_todays_prs

# Fetch and display reviewed PRs
fetch_reviewed_prs
