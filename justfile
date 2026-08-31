teams_file := justfile_directory() + "/media/teams_private.json"

[private]
@default:
  just --list

# regenerate teams pages
@regenerate-teams-pages:
  #!/usr/bin/env sh
  Rscript ./R/generate_quarto_teams.R
  quarto render

# which new teams to assess?
@teams-new:
  #!/usr/bin/env sh
  Rscript ./R/teams_new.R

# which teams in the limbo?
@teams-limbo:
  #!/usr/bin/env sh
  Rscript ./R/teams_limbo.R

# list valid teams
@teams-valid:
  #!/usr/bin/env sh
  Rscript ./R/teams_valid.R

# list teams' members
@members:
  #!/usr/bin/env sh
  Rscript ./R/get_members.R
