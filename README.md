# GitHub-Daily-Report

This script tracks various GitHub activities for a specified user, including pull requests created, and pull requests reviewed.

## Prerequisites

- **jq**: A lightweight and flexible command-line JSON processor. Install it using:

  ```sh
  brew install jq
  ```

- **GitHub Personal Access Token**: Generate a token with the necessary permissions from your GitHub account settings.

## Setup

1. **Clone the repository**:

   ```sh
   git clone https://github.com/your-username/github-activity-tracker.git
   cd github-activity-tracker
   ```

2. **Set up environment variables**:
   Export your GitHub username and personal access token as environment variables:

   ```sh
   export GITHUB_USER="your-github-username" 
   export GITHUB_TOKEN="your-personal-access-token"
   ```

## Usage

Run the script:

```sh
./main.sh
```

## Output

The script will output the following activities for the current day:

1. **Pull Requests Created**: Lists all pull requests created by the user.
2. **Pull Requests Reviewed**: Lists all pull requests reviewed by the user.

Each section will display relevant details such as title, repository, status, creation date, and URL.

## Example Output

```
Pull Requests

1. Title: Fix bug in authentication
  a. Repository: your-username/repo-name
  b. Status: open
  c. Created At: 2023-10-02T12:34:56Z
  d. URL: https://github.com/your-username/repo-name/pull/1

Reviewed Pull Requests

1. Title: Add new feature
  a. Repository: another-user/repo-name
  b. Status: closed (Merged)
  c. Created At: 2023-10-02T12:34:56Z
  d. URL: https://github.com/another-user/repo-name/pull/2

```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.
