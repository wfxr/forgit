function forgit::inside_work_tree
    git rev-parse --is-inside-work-tree >/dev/null;
end
