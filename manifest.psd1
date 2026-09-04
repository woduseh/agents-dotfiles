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
    )

    Directories = @()

    SkillSourceRoot   = '.agents/skills'
    SkillInstallRoots = @(
        '.agents/skills'
        '.claude/skills'
    )

    Skills = @()

    # Keep removal entries so machines that missed earlier syncs also uninstall them.
    RemovedSkills = @(
        'creative-lore-consolidation'
        'creative-worldbuilding'
        'creative-writing'
        'prompt-engineering'
        'release-prep'
        'work-continuity'
    )
}
