cd lib/features

feature=$1

mkdir $feature; cd $feature;
path_prefix="lib/features/${feature}"
datasource_path="${path_prefix}/data/datasource"
models_path="${path_prefix}/data/models"
repos_path="${path_prefix}/data/repositories"

bloc_path="${path_prefix}/presentation/bloc"
pages_path="${path_prefix}/presentation/pages"
widgets_path="${path_prefix}/presentation/widgets"

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



