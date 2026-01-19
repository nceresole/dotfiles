# =============================================================================
# Python Configuration
# Topic: python.zsh
# =============================================================================

# -----------------------------------------------------------------------------
# Python Aliases
# -----------------------------------------------------------------------------
alias py='python3'
alias python='python3'
alias pip='pip3'

# Virtual environment
alias va='source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias venv='python3 -m venv .venv'

# uv package manager
alias pipi='uv pip install'
alias pipu='uv pip uninstall'
alias pipf='uv pip freeze > requirements.txt'

# FastAPI development
alias uvicorn-dev='uvicorn main:app --reload'
alias uvicorn-prod='uvicorn main:app --host 0.0.0.0 --port 8000'

# -----------------------------------------------------------------------------
# Python Environment Variables
# -----------------------------------------------------------------------------
export PYTHONDONTWRITEBYTECODE=1  # Prevent .pyc files
export PYTHONUNBUFFERED=1         # Force unbuffered output

# -----------------------------------------------------------------------------
# Python Functions
# -----------------------------------------------------------------------------

# Smart virtual environment activation
# Tries .venv first, then venv
env-activate() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
        echo "Activated .venv"
    elif [ -d "venv" ]; then
        source venv/bin/activate
        echo "Activated venv"
    else
        echo "No virtual environment found (.venv or venv)"
        return 1
    fi
}

# Create new Python project with uv
newpy() {
    if [ -z "$1" ]; then
        echo "Usage: newpy <project-name>"
        return 1
    fi

    uv init "$1"
    cd "$1"
    echo "3.12" > .python-version
    uv venv
    echo "Created Python project: $1"
    echo "Run 'source .venv/bin/activate' to activate"
}

# Create FastAPI project structure
newfastapi() {
    if [ -z "$1" ]; then
        echo "Usage: newfastapi <project-name>"
        return 1
    fi

    # Create project
    uv init "$1"
    cd "$1"
    echo "3.12" > .python-version
    uv venv
    source .venv/bin/activate

    # Install FastAPI dependencies
    uv pip install fastapi uvicorn sqlalchemy pydantic python-dotenv

    # Create basic structure
    mkdir -p app/{api,models,schemas,services}
    touch app/__init__.py
    touch app/api/__init__.py
    touch app/models/__init__.py
    touch app/schemas/__init__.py
    touch app/services/__init__.py

    # Create main.py
    cat > app/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI(title="My API")

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
EOF

    # Create .env
    cat > .env << 'EOF'
DATABASE_URL=sqlite:///./app.db
SECRET_KEY=your-secret-key-here
DEBUG=True
EOF

    # Create .gitignore
    cat > .gitignore << 'EOF'
.venv/
__pycache__/
*.pyc
.env
*.db
.DS_Store
EOF

    echo "Created FastAPI project: $1"
    echo "Structure:"
    tree -L 2 -I '.venv|__pycache__' 2>/dev/null || find . -maxdepth 2 -type d | head -20
    echo ""
    echo "To run: uvicorn app.main:app --reload"
}

# Quick Python HTTP server
serve() {
    local port="${1:-8000}"
    echo "Starting server on http://localhost:$port"
    python3 -m http.server "$port"
}
