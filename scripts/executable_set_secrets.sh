#!/bin/bash

if [ -f ~/.config/secrets/gh_token ]; then
    GH_TOKEN=$(<~/.config/secrets/gh_token)
    export GITHUB_TOKEN="$GH_TOKEN"
fi

if [ -f ~/.config/secrets/open_ai ]; then
    OPENAI_API_KEY=$(<~/.config/secrets/open_ai)
    export OPENAI_API_KEY="$OPENAI_API_KEY"
fi

if [ -f ~/.config/secrets/gemini_api_key ]; then
    GEMINI_API_KEY=$(<~/.config/secrets/gemini_api_key)
    export GEMINI_API_KEY="$GEMINI_API_KEY"
fi

export GOPRIVATE=github.com/AcordoCertoBR
