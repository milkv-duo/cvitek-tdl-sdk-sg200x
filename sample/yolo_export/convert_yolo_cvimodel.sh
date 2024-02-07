# source env
# source tpu_mlir_1_2/envsetup.sh

# setup
# change setting to your model and path
##############################################


chip=cv181x # 芯片型号
model_name="yolov5m" # 转换的模型型号
version_name="9_branch" # 模型的版本号，可以随意自定义
output_layer="" # 模型输出层，仅自动添加在最后生成模型后缀
root=${model_name} # 模型根路径
img_dir="../dataset/COCO2017_100/" # 用于calibration的图片文件夹目录
img="../dataset/COCO2017_100/000000000632.jpg" # 用于生成单张mlir图片


#############################################

mlir="${root}/mlir/${version_name}_fp32.mlir"
table="${root}/calibration_table/${version_name}_cali_table"
cvimodel="${root}/int8/${model_name}_${chip}.cvimodel"

model_onnx="${root}/onnx/${model_name}.onnx"
in_npz="${model_name}_in_f32.npz"
out_npz="${root}/npz/${model_name}_top_outputs.npz"

mkdir "${root}/mlir"
mkdir "${root}/calibration_table"
mkdir "${root}/int8"
mkdir "${root}/npz"


# mlir step
#################################
if [ $1 = 1 -o $1 = "all" ] ; then

    model_transform.py \
    --model_name ${model_name} \
    --model_def ${model_onnx} \
    --input_shapes [[1,3,640,640]] \
    --mean 0.0,0.0,0.0 \
    --scale 0.0039216,0.0039216,0.0039216 \
    --keep_aspect_ratio \
    --pixel_format rgb \
    --test_input ${img} \
    --test_result ${out_npz} \
    --mlir ${mlir}
fi

# calibration_table step
################################
if [ $1 = 2 -o $1 = "all" ] ; then

    run_calibration.py ${mlir} \
    --dataset ${img_dir} \
    --input_num 350 \
    -o ${table}

fi

if [ $1 = 3 -o $1 = "all" -o $1 = "deploy" ] ; then

    model_deploy.py \
    --mlir ${mlir} \
    --quant_input \
    --quant_output \
    --quantize INT8 \
    --calibration_table ${table} \
    --chip ${chip} \
    --test_input ${in_npz} \
    --test_reference ${out_npz} \
    --tolerance 0.85,0.45 \
    --model ${cvimodel}

fi
