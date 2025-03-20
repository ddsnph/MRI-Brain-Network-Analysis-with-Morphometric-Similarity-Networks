import sys
import nibabel as nib
import json

def extract_slice_timing(nifti_file):
    try:
        img = nib.load(nifti_file)
        header = img.header
        repetition_time = header.get_zooms()[3]  # Extract TR
        num_slices = img.shape[2]  # Extract number of slices

        # Generate slice timing values
        slice_times = [(i * repetition_time) / num_slices for i in range(num_slices)]
        print(json.dumps(slice_times))
        return json.dumps(slice_times)
    except Exception as e:
        print(json.dumps([]))  # Return empty array if error
        sys.exit(1)

if __name__ == "__main__":
    nifti_file = sys.argv[1]
    print(extract_slice_timing(nifti_file))
