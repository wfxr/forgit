function forgit::warn
    printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$argv" >&2;
end
