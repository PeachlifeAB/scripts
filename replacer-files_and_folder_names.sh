for file in $(find . -not -path '*/\.git/*' -name "*addictHelper*")
do 
    mv -v "$file" "${file/addictHelper/Reduce}";
done
