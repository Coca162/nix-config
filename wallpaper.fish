cd ~/Pictures/Wallpapers/

set -g index (math (cat current.txt) + 1)
set images (command ls images | sort -n)

if test $index -gt (count $images)
    set -g index 1
end

swww img images/$images[$index]
echo $index > current.txt