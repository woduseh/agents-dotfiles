@{
    Files = @(
        @{
            Name       = 'Codex global instructions'
            Home       = '.codex/AGENTS.md'
            Repository = 'config/codex/AGENTS.md'
        }
        @{
            Name       = 'Claude global instructions'
            Home       = '.claude/CLAUDE.md'
            Repository = 'config/claude/CLAUDE.md'
        }
        @{
            Name       = 'Claude advisor subagent'
            Home       = '.claude/agents/advisor.md'
            Repository = 'config/claude/agents/advisor.md'
        }
    )

    Directories = @()

    SkillSourceRoot   = '.agents/skills'
    SkillInstallRoots = @(
        '.agents/skills'
        '.claude/skills'
    )

    Skills = @('engineering-review', 'test-audit', 'explain-with-artifacts', 'pre-compact')

    # Keep removal entries so machines that missed earlier syncs also uninstall them.
    RemovedSkills = @(
        'codebase-design'
        'commit-context'
        'creative-lore-consolidation'
        'creative-worldbuilding'
        'creative-writing'
        'delegate-research'
        'prompt-engineering'
        'release-prep'
        'work-continuity'
    )

    RemovedPaths = @(
        '.claude/guides'
    )

    ClaudeSettings        = '.claude/settings.json'
    ClaudePermissionRules = @{
        Deny = @(
            'Read(~/.ssh/id_*)'
            'Read(~/.codex/auth.json)'
            'Read(~/.claude/.credentials.json)'
        )
        Ask  = @(
            'Bash(git push *--force*)'
            'Bash(git push -f*)'
            'Bash(git push * -f*)'
            'Bash(gh pr merge *--admin*)'
            'Bash(gh release create *)'
            'Bash(npm publish *)'
            'PowerShell(git push *--force*)'
            'PowerShell(git push -f*)'
            'PowerShell(git push * -f*)'
            'PowerShell(gh pr merge *--admin*)'
            'PowerShell(gh release create *)'
            'PowerShell(npm publish *)'
        )
    }
}
