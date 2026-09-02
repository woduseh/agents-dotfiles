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

    Skills = @(
        'agent-orchestration'
        'coding-workflow'
        'creative-brainstorming'
        'creative-character'
        'creative-lore-consolidation'
        'creative-revision'
        'creative-worldbuilding'
        'creative-writing'
        'engineering-investigation-subagents'
        'image-generation'
        'prompt-design'
        'prompt-evaluation'
        'prompt-revision'
        'release-prep'
        'work-continuity'
    )
}
