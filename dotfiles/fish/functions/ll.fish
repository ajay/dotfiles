function ll --wraps=ls
    LC_COLLATE=C ls -l --group-directories-first $argv
end
