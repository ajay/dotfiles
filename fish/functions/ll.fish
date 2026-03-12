function ll --wraps=ls --wraps='ls -l --group-directories-first' --description 'alias ll=ls -l --group-directories-first'
    LC_COLLATE=C ls -l --group-directories-first $argv
end
