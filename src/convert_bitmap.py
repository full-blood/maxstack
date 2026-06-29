from pathlib import Path
import sys

from PIL import Image, ImageOps


Image.MAX_IMAGE_PIXELS = None


def to_jpeg_compatible(image):
    if image.mode in ("I;16", "I;16L", "I;16B", "I;16N"):
        return image.point(lambda value: value / 257).convert("L")

    if image.mode == "I":
        min_value, max_value = image.getextrema()
        if min_value >= 0 and max_value <= 255:
            return image.convert("L")
        if min_value >= 0 and max_value <= 65535:
            return image.point(lambda value: value / 257).convert("L")
        if max_value > min_value:
            scale = 255.0 / (max_value - min_value)
            return image.point(lambda value: (value - min_value) * scale).convert("L")
        return image.point(lambda value: 0).convert("L")

    if image.mode == "F":
        min_value, max_value = image.getextrema()
        if max_value > min_value:
            scale = 255.0 / (max_value - min_value)
            return image.point(lambda value: (value - min_value) * scale).convert("L")
        return image.point(lambda value: 0).convert("L")

    if image.mode == "LA":
        return image.getchannel("L")

    if image.mode in ("L", "RGB"):
        return image

    return image.convert("RGB")


def convert_to_jpg(source_path, max_dimension):
    source = Path(source_path)
    output = source.with_name(f"{source.stem}_small.jpg")

    with Image.open(source) as image:
        icc_profile = image.info.get("icc_profile")
        image = ImageOps.exif_transpose(image)
        image = to_jpeg_compatible(image)

        if max_dimension > 0:
            width, height = image.size
            largest_side = max(width, height)
            if largest_side > max_dimension:
                scale = max_dimension / float(largest_side)
                new_size = (
                    max(1, int(round(width * scale))),
                    max(1, int(round(height * scale))),
                )
                image = image.resize(new_size, Image.Resampling.LANCZOS)

        save_options = {
            "quality": 95,
            "optimize": True,
            "subsampling": 0,
        }

        if icc_profile:
            save_options["icc_profile"] = icc_profile

        image.save(output, "JPEG", **save_options)

    return output


def main():
    if len(sys.argv) < 2:
        print("Usage: convert_bitmap.py <bitmap_path> [max_dimension]")
        return 2

    source_path = sys.argv[1]
    max_dimension = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    output = convert_to_jpg(source_path, max_dimension)
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
