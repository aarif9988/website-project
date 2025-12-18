# publish_to_github.ps1
# Installs Git & GitHub CLI (if possible), initializes the repo, and uses gh to create a public repo named 'website-project' and push.
# Run this script from the project root in Windows PowerShell (Run as Administrator if installing packages).

param(
    [string]$RepoName = "website-project",
    [switch]$SkipInstall
)

function Run-Command {
    param($cmd)
    Write-Host "> $cmd"
    & powershell -NoProfile -Command $cmd
}

# Optionally install Git and GH using winget
if (-not $SkipInstall) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Please install Git (https://git-scm.com/download/win) and optionally GitHub CLI (https://cli.github.com/) manually, then re-run this script with -SkipInstall." -ForegroundColor Yellow
    } else {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Git..." -ForegroundColor Cyan
            winget install --id Git.Git -e --source winget
        } else { Write-Host "Git already installed." }

        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            Write-Host "Installing GitHub CLI (gh)..." -ForegroundColor Cyan
            winget install --id GitHub.cli -e --source winget
        } else { Write-Host "GitHub CLI already installed." }
    }
}

# Ensure git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "git is not available. Please install Git and re-run the script." -ForegroundColor Red
    exit 1
}

# Configure user if not set
$name = git config --global user.name
$email = git config --global user.email
if (-not $name) {
    $inputName = Read-Host "Enter your Git user.name (e.g. 'Arif Amirov')"
    if ($inputName) { git config --global user.name "$inputName" }
}
if (-not $email) {
    $inputEmail = Read-Host "Enter your Git user.email (e.g. you@example.com)"
    if ($inputEmail) { git config --global user.email "$inputEmail" }
}

# Initialize repo if needed
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

# Add and commit
git add .
# Only commit if there are staged changes
$changes = git diff --cached --name-only
if ($changes) {
    git commit -m "Initial commit — portfolio site"
} else {
    Write-Host "No changes to commit." -ForegroundColor Yellow
}

# If gh is available, use it to create & push; otherwise ask for remote URL
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Authenticating gh (opens browser). If already authenticated, it will skip." -ForegroundColor Cyan
    gh auth login --web

    # Create repo and push
    Write-Host "Creating GitHub repository '$RepoName' (public) and pushing..." -ForegroundColor Cyan
    gh repo create $RepoName --public --source=. --remote=origin --push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository created and pushed. Visit: https://github.com/$(gh api user --jq .login)/$RepoName" -ForegroundColor Green
    } else {
        Write-Host "gh command failed. Please create the repo manually on GitHub and then run the git remote/push commands." -ForegroundColor Red
    }
} else {
    Write-Host "gh CLI not found. Create a repository named '$RepoName' on GitHub, then run these commands:" -ForegroundColor Yellow
    Write-Host "git remote add origin https://github.com/aarif9988/$RepoName.git"
    Write-Host "git push -u origin main"
}
