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
}
