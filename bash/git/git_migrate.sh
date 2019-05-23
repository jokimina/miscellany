BASE_DIR=$1
CODE_DIRS=$(find $BASE_DIR -name ".git" | xargs -i  readlink -f {} | sed 's/.git//')
for d in $CODE_DIRS 
do
  echo "Check $d"
  cd $d
  if ! git remote -v | grep -q "code.old.com";then
    echo "[$d] not code.old.com, skip.."
    continue
  fi 

  old_remote=$(git remote -v | awk '/code.old.com/{print $2;exit}')
  new_remoet=$(echo $old_remote | sed 's/code.old.com/code.new.com/')
  echo "Change $old_remote -> $new_remoet"
  if ! git remote | grep -q old;then
    git remote add old $old_remote
  fi
  git remote set-url origin $new_remoet
  git branch -r | grep -vE '\->|old/' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
  git pull --all 2>/dev/null
  echo "Push all to $new_remoet"
  git push origin --all
done

