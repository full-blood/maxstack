# resize_map.py
import sys
from pathlib import Path
from PIL import Image, ImageOps
Image.MAX_IMAGE_PIXELS = None

def resize_image(input_path, max_size=1024):
    input_path = Path(input_path)
    if not input_path.exists():
        print(f"File not found: {input_path}")
        return

    # Créer le nom de sortie
    output_path = input_path.with_name(input_path.stem + "_small" + input_path.suffix)

    # Ouvrir l'image
    with Image.open(input_path) as img:
        orig_width, orig_height = img.size

        # Calculer le ratio pour conserver les proportions
        ratio = min(max_size / orig_width, max_size / orig_height)
        if ratio >= 1:
            # L'image est déjà plus petite que max_size
            img.save(output_path)
            print(f"Image already small, saved copy: {output_path}")
            return output_path

        new_width = int(orig_width * ratio)
        new_height = int(orig_height * ratio)

        # Redimensionner et sauvegarder
        img_resized = img.resize((new_width, new_height), Image.LANCZOS)
        img_resized.save(output_path)
        print(f"Resized {input_path.name}: {orig_width}x{orig_height} -> {new_width}x{new_height}")
        return output_path

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python resize_map.py <image_path> [max_size]")
        sys.exit(1)

    image_path = sys.argv[1]
    max_size = int(sys.argv[2]) if len(sys.argv) > 2 else 1024
    resize_image(image_path, max_size)