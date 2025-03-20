$sourceDir = "C:\Users\monka\Downloads\chessdata\chessdata\imaging_data_chess"
$destDir = "C:\Users\monka\Downloads\BIDS_FINAL"

# Create BIDS dataset structure
New-Item -ItemType Directory -Path "$destDir" -Force
New-Item -ItemType Directory -Path "$destDir\derivatives" -Force
New-Item -ItemType Directory -Path "$destDir\code" -Force

# Add dataset description
Set-Content "$destDir\dataset_description.json" '{
    "Name": "Chess Players MRI Study",
    "BIDSVersion": "1.8.0",
    "License": "CC0",
    "Authors": ["Your Name"]
}'

# Loop through each subject folder
Get-ChildItem -Path $sourceDir -Directory | ForEach-Object {
    $subjectID = $_.Name
    Write-Output "Processing subject: $subjectID"

    # Create BIDS subject directories
    $subDest = "$destDir\sub-$subjectID"
    New-Item -ItemType Directory -Path "$subDest\anat" -Force
    New-Item -ItemType Directory -Path "$subDest\dwi" -Force
    New-Item -ItemType Directory -Path "$subDest\func" -Force

    # Move anatomical file (anat.nii.gz)
    if (Test-Path "$sourceDir\$subjectID\anat_1\anat.nii.gz") {
        Copy-Item "$sourceDir\$subjectID\anat_1\anat.nii.gz" "$subDest\anat\sub-${subjectID}_T1w.nii.gz" -Force
        Set-Content "$subDest\anat\sub-${subjectID}_T1w.json" '{
            "Manufacturer": "Siemens",
            "MagneticFieldStrength": 3,
            "RepetitionTime": 1.9,
            "EchoTime": 2.26,
            "FlipAngle": 12,
            "SliceThickness": 1.0,
            "VoxelSize": [1, 1, 1]
        }'
    } else {
        Write-Output "❌ Missing anatomical file for subject $subjectID"
    }

    # Move DWI files
    if (Test-Path "$sourceDir\$subjectID\dti_1\dti.nii.gz") {
        Copy-Item "$sourceDir\$subjectID\dti_1\dti.nii.gz" "$subDest\dwi\sub-${subjectID}_dwi.nii.gz" -Force
        Copy-Item "$sourceDir\$subjectID\dti_1\dti.bval" "$subDest\dwi\sub-${subjectID}_dwi.bval" -Force
        Copy-Item "$sourceDir\$subjectID\dti_1\dti.bvec" "$subDest\dwi\sub-${subjectID}_dwi.bvec" -Force
        Set-Content "$subDest\dwi\sub-${subjectID}_dwi.json" '{
            "Manufacturer": "Siemens",
            "MagneticFieldStrength": 3,
            "RepetitionTime": 2.5,
            "EchoTime": 0.09,
            "FlipAngle": 90,
            "PhaseEncodingDirection": "j-",
            "EffectiveEchoSpacing": 0.00078,
            "TotalReadoutTime": 0.032
        }'
    } else {
        Write-Output "❌ Missing DWI file for subject $subjectID"
    }

    # Move Functional MRI (rest.nii.gz)
    if (Test-Path "$sourceDir\$subjectID\rest_1\rest.nii.gz") {
        Copy-Item "$sourceDir\$subjectID\rest_1\rest.nii.gz" "$subDest\func\sub-${subjectID}_task-rest_bold.nii.gz" -Force

        # Extract slice timing via Python
        Write-Output "Extracting slice timing for $subjectID..."
        $sliceTiming = python extract_slice_timing.py "$subDest\func\sub-${subjectID}_task-rest_bold.nii.gz"

        # Add extracted slice timing into JSON
        Set-Content "$subDest\func\sub-${subjectID}_task-rest_bold.json" "{
            `"TaskName`": `"rest`",
            `"RepetitionTime`": 2.0,
            `"SliceTiming`": $sliceTiming
        }"
    } else {
        Write-Output "❌ Missing functional file for subject $subjectID"
    }

    Write-Output "✅ Subject $subjectID organized in BIDS format"
}

Write-Output "✅ All subjects processed successfully!"
