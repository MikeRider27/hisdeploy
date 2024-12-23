#!/bin/sh

set -o errexit

echo "
#!/bin/sh

modified=\$(git diff --cached --name-only --diff-filter=ACMR)

[[ -z \$modified ]] && exit 0

DEFAULT_GRP="hispydevelopteam"

for f in \$modified; do
    chgrp \$DEFAULT_GRP \$f
    git add \$f
done
" > .git/hooks/pre-commit

chmod +x .git/hooks/pre-commit

echo "update-group-hook installed to .git/hooks/pre-commit!"
