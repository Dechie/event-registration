feature=$1

path_prefix="lib/features/${feature}"
mkdir $path_prefix; cd $path_prefix;
datasource_path="data/datasource"
models_path="data/models"
repos_path="data/repositories"

bloc_path="presentation/bloc"
pages_path="presentation/pages"
widgets_path="presentation/widgets"

mkdir -p $datasource_path $models_path $repos_path 
mkdir -p $bloc_path $pages_path $widgets_path

echo "${datasource_path}/${feature}_datasource.dart"
touch "${datasource_path}/${feature}_datasource.dart"
echo "${repos_path}/${feature}_repository.dart"
touch "${repos_path}/${feature}_repository.dart"
touch "${repos_path}/${feature}_repository.dart"
touch "${bloc_path}/${feature}_bloc.dart"
touch "${bloc_path}/${feature}_event.dart"
touch "${bloc_path}/${feature}_state.dart"
touch "${pages_path}/${feature}_page.dart"



