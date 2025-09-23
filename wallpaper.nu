cd ~/Pictures/Wallpapers/;
mut index: int = open current.txt | into int;
let images: list<string> = ls images | get name | sort -n;

$index = $index + 1;
if ($index >= ($images | length)) {
    $index = 0
}

$images | get $index | swww img $in;
$index | save current.txt --force;
