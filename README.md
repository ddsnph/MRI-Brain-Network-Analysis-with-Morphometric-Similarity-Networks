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
.
├── scripts/  
│   ├── convert_to_bids.py  
│   ├── extract_morphometrics.py  
│   ├── build_msn.py  
│   ├── threshold_graph.py  
│   ├── compute_graph_metrics.py  
│   ├── cluster_analysis.py  
│   ├── visualize_networks.py  
│   ├── utils_io.py  
│   └── utils_graph.py  
├── notebooks/  
│   └── fMRI_BIDS_MSN_to_Kmeans.ipynb  
├── data/  
│   ├── raw/  
│   ├── bids/  
│   └── subjects.tsv  
├── freesurfer/  
├── results/  
│   ├── features/  
│   ├── msns/  
│   ├── graphs/  
│   ├── metrics/  
│   ├── clusters/  
│   └── figures/  
├── requirements.txt  
└── README.md  

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
while read -r sid ddir t1rel; do  
  if [ "$sid" = "subject_id" ]; then continue; fi  
  t1="data/bids/${t1rel}"  
  recon-all -i "$t1" -s "$sid" -all  
done < data/subjects.tsv  

# 4) Extract morphometrics  
python scripts/extract_morphometrics.py --subjects_dir "$SUBJECTS_DIR" --atlas dk --out_dir results/features  

# 5) Build MSNs  
python scripts/build_msn.py --features_dir results/features --zscore_within_subject --out_dir results/msns  

# 6) Threshold graphs  
python scripts/threshold_graph.py --msn_dir results/msns --density 0.15 --out_dir results/graphs  

# 7) Graph metrics  
python scripts/compute_graph_metrics.py --graphs_dir results/graphs --out_dir results/metrics  

# 8) Cluster analysis  
python scripts/cluster_analysis.py --msn_dir results/msns --k_min 2 --k_max 5 --n_init 100 --out_dir results/clusters  

# 9) Visualizations  
python scripts/visualize_networks.py --msn_dir results/msns --graphs_dir results/graphs --metrics_dir results/metrics --out_dir results/figures  

## 6) Step-by-step with arguments
6.1 DICOM to BIDS  
python scripts/convert_to_bids.py --input data/raw --output data/bids --force_convert  
bids-validator data/bids  

6.2 FreeSurfer recon-all  
recon-all -i data/bids/anat/<subject>_T1w.nii.gz -s <subject> -all  

6.3 Extract morphometrics  
python scripts/extract_morphometrics.py --subjects_dir "$SUBJECTS_DIR" --atlas dk --metrics thickness thickness_std area volume meancurv gauscurv foldind curvind --out_dir results/features  

6.4 Build MSNs  
python scripts/build_msn.py --features_dir results/features --zscore_within_subject --similarity pearson --out_dir results/msns  

6.5 Threshold graphs  
python scripts/threshold_graph.py --msn_dir results/msns --density 0.15 --keep_positive_only --out_dir results/graphs  

6.6 Graph metrics  
python scripts/compute_graph_metrics.py --graphs_dir results/graphs --metrics global local clustering degree --out_dir results/metrics  

6.7 Clustering  
python scripts/cluster_analysis.py --msn_dir results/msns --vectorize upper --k_min 2 --k_max 5 --n_init 100 --random_state 42 --out_dir results/clusters  

6.8 Visualizations  
python scripts/visualize_networks.py --msn_dir results/msns --graphs_dir results/graphs --metrics_dir results/metrics --parcel_labels resources/desikan_labels.csv --out_dir results/figures  

## 7) Reproducing GM results
Use density 0.15 for main figures  
Run sensitivity at 0.10, 0.20, 0.25, 0.30  
Z-score features within subject  
k-means with k=2–5, pick best by silhouette  

## 8) Troubleshooting
Slice timing errors: re-run convert with --slice_timing auto  
Skull strip failures: -noskullstrip with custom mask  
NaN correlations: ensure all 68 regions present, no zero-variance features  

## 9) Provenance
Python 3.8.1/3.10  
FreeSurfer 7.4.1  
Desikan–Killiany atlas (68 cortical regions)  
Pearson correlation for MSN  
Random seed 42 for clustering  

## 10) Citation
Sutton, M. (2025). Structural Homogeneity of Chess Grandmasters Revealed by Morphometric Similarity Networks. University of Missouri.  

## 11) License
MIT License
