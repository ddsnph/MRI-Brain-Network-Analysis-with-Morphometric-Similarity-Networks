# BIDS → FreeSurfer → Morphometric Similarity Networks → Clustering
Reproducible neuroimaging pipeline that takes raw MRI DICOMs to:  
1) BIDS-compliant dataset  
2) FreeSurfer morphometrics  
3) Morphometric Similarity Networks (MSNs)  
4) Graph theory metrics  
5) K-means clustering and figures  

## 1) What you get at the end
- BIDS dataset that passes the BIDS Validator  
- FreeSurfer recon-all outputs for each subject  
- Per-region feature tables (68 DK parcels × 8 morphometrics)  
- Per-subject MSNs (68×68), both full weighted and thresholded graphs  
- Graph metrics tables (global and nodal)  
- K-means clustering results with silhouette scores  
- Figures: adjacency heatmaps, surface maps, metric boxplots  

## 2) Repo layout
```text
├── scripts/  
│   ├── convert_to_bids.ps1  
│   ├── extract_slice_timing.py  
├── notebooks/  
│   └── fMRI_BIDS_MSN_to_Kmeans.ipynb  
└── README.md
```  

## 3) Requirements
- Linux or macOS  
- Python 3.8+  
- FreeSurfer 7.4.1 installed and sourced  
- BIDS Validator  

### 3.1 Create environment
python -m venv .venv  
source .venv/bin/activate  
pip install -r requirements.txt  

requirements.txt should include:  
numpy  
pandas  
scipy  
scikit-learn  
networkx  
matplotlib  
seaborn  
nibabel  
bids-validator  

### 3.2 FreeSurfer setup
export FREESURFER_HOME=/path/to/freesurfer/7.4.1  
source $FREESURFER_HOME/SetUpFreeSurfer.sh  
export SUBJECTS_DIR=$(pwd)/freesurfer  
mkdir -p "$SUBJECTS_DIR"  

## 4) Inputs
DICOMs in data/raw/<subject_id>/...  

A data/subjects.tsv file:  
subject_id	dicom_dir	t1_relpath  
sub-0001	data/raw/sub-0001	anat/sub-0001_T1w.nii.gz  
sub-0002	data/raw/sub-0002	anat/sub-0002_T1w.nii.gz  

## 5) End-to-end quick start
source .venv/bin/activate  
source $FREESURFER_HOME/SetUpFreeSurfer.sh  
export SUBJECTS_DIR=$(pwd)/freesurfer  

# 1) DICOM -> BIDS  
python scripts/convert_to_bids.py --input data/raw --output data/bids  

# 2) Validate BIDS  
bids-validator data/bids  

# 3) FreeSurfer  
run freesurfer recon-all on multiple subject using screens

# 4) Extract morphometrics  
extra stats for left and right hemisphere of brain [lh.aparc & rh.aparc]

# 5) Build MSNs   
Build morphometric similarity networks [refer to colab notebook]

# 6) Threshold graphs  
compute thresholds [refer to colab notebook]

# 7) Graph metrics  
[refer to colab notebook]

# 8) Cluster analysis  
[refer to colab notebook]

# 9) Visualizations  
view within the colab notebook


## 7) Reproducing GM results 
Z-score features within subject  
k-means with k=2–5, pick best by silhouette  
