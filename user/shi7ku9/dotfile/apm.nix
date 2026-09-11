{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      home.file.".apm/config.json".text = ''
        {
          "auto_integrate": true,
          "install_target": "codex,opencode"
        }
      '';

      home.file.".apm/apm.yml".text = ''
        name: shi7ku9
        version: 1.0.0
        description: APM project for shi7ku9
        author: shi7ku9
        dependencies:
          apm:
            - mattpocock/skills
            - anthropics/skills/skills/frontend-design
            - anthropics/skills/skills/pdf
          mcp: []
        includes: auto
        scripts: {}
      '';
    };
}
