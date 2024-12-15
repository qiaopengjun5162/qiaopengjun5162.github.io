+++
title = "量化学习之 jupyter notebook 环境配置"
date = 2023-12-09T11:05:59+08:00
[taxonomies]
tags= ["Python"]
categories= ["Python"]
+++

# 量化学习之 jupyter notebook 环境配置

```shell
# 安装 anaconda
conda create -n jupyter python=3.8
conda activate jupyter

# 安装 jupyter notebook
pip install jupyter

# 安装 jupyter lab
pip install jupyterlab

# 安装 jupyter lab extensions
jupyter labextension install @jupyterlab/toc
jupyter labextension install @jupyterlab/git
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/plotly-extension
jupyter labextension install @jupyterlab/celltags
jupyter labextension install @jupyterlab/toc
jupyter labextension install @jupyterlab/launcher
jupyter labextension install @jupyterlab/shortcuts
jupyter labextension install @jupyterlab/debugger
jupyter labextension install @jupyterlab/running
jupyter labextension install @jupyterlab/vega5-extension
jupyter labextension install @jupyterlab/hub-extension
jupyter labextension install @jupyterlab/vdom
jupyter labextension install @jupyterlab/theme-dark-extension
jupyter labextension install @jupyterlab/theme-light-extension
jupyter labextension install @jupyterlab/virtual-gl
jupyter labextension install @jupyterlab/fasta-extension
jupyter labextension install @jupyterlab/geojson-extension
jupyter labextension install @jupyterlab/mathjax3-extension
jupyter labextension install @jupyterlab/vega5-extension
jupyter labextension install @jupyterlab/toc
jupyter labextension install @jupyterlab/celltags
jupyter labextension install @jupyterlab/plotly-extension
jupyter labextension install @jupyterlab/celltags


# 安装 jupyter notebook
conda install jupyter notebook
# 创建虚拟环境
conda create -n quantify_python_3_12 python=3.12
# 激活虚拟环境
conda activate quantify_python_3_12
# 查看虚拟环境列表
conda env list
# 安装AKShare
pip install akshare  --upgrade
# 安装 Tushare
pip install tushare
# 安装Empyrical （安装失败）
pip install empyrical -i https://pypi.tuna.tsinghua.edu.cn/simple
# 安装 QuantStats
pip install quantstats --upgrade --no-cache-dir
# 安装 prompt_toolkit
pip install prompt_toolkit

# 确认是否安装 ipykernel
python -m ipykernel --version

# 安装 ipykernel
pip install ipykernel

# 添加内核到jupyter
python -m ipykernel install --user --name=quantify_python_3_12 --display-name quantify_python_3_12

# 查看内核
jupyter kernelspec list

# 启动jupyter
jupyter notebook
```
