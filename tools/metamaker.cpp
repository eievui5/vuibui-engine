#include <cstdlib>
#include <cstring>
#include <fstream>
#include <getopt.h>
#include <iostream>
#include <string>
#include <vector>

const char* GB_SHADES[4] = {" ", "░", "▒", "▓"};
const char HELP_MESSAGE[] = \
"Usage: ./metamaker [-o <tileset out>] -m <metatile out> -w <tileset width> -i <input>\n"
"Options:\n"
"    -h, --help             Show this message."
"    -i, --input <path>     Path to the input tileset.\n"
"    -m, --metatiles <path> Path to the output .asm file containing the metatile data.\n"
"    -O, --offset <value>   Optional VRAM index of the first tile.\n"
"    -o, --output <path>    Optional path to the output optimized tileset.\n"
"    -w, --width <value>    Width of the input tileset.\n";

static struct option const longopts[] = {
    {"help",      no_argument,       NULL, 'h'},
    {"input",     required_argument, NULL, 'i'},
    {"metatiles", required_argument, NULL, 'm'},
    {"offset",    required_argument, NULL, 'O'},
    {"output",    required_argument, NULL, 'o'},
    {"width",     required_argument, NULL, 'w'},
    {NULL,        no_argument,       NULL, 0}
};
static const char shortopts[] = "hi:m:O:o:w:";

class GBTile {
public:
    char data[16];

    GBTile(char* bytes) {
        std::memcpy(data, bytes, 16);
    }

    bool operator==(GBTile rhs) {
        return std::memcmp(data, rhs.data, 16) == 0;
    }
};

void fatal(std::string str) {
    std::cerr << "FATAL: " << str << '\n';
    exit(1);
}

int main(int argc, char* argv[]) {
    std::string input_file_argument;
    std::string output_tileset_argument;
    std::string output_data_argument;
    int metatile_width = 0;
    int vram_offset = 0;
    char option_char;

    // Parse command-line options.
    while ((option_char = getopt_long_only(argc, argv, shortopts, longopts, NULL)) != -1) {
        switch (option_char) {
        case 'h':
            std::cout << HELP_MESSAGE;
            std::exit(0);
        case 'i':
            input_file_argument = optarg;
            break;
        case 'm':
            output_data_argument = optarg;
            break;
        case 'O':
            try {
                vram_offset = std::stoi(optarg);
            } catch (const std::invalid_argument& ia) {
                fatal("Invalid offset input.");
            }
            break;
        case 'o':
            output_tileset_argument = optarg;
            break;
        case 'w':
            try {
                metatile_width = std::stoi(optarg) * 2;
            } catch (const std::invalid_argument& ia) {
                fatal("Invalid width input.");
            }
            break;
        }
    }

    // Validate inputs
    if (input_file_argument.length() == 0)
        fatal("Missing input file.");
    if (output_data_argument.length() == 0)
        fatal("Missing output file.");
    if (metatile_width <= 0)
        fatal("Invalid or missing width.");

    // Open and read the input binary file.
    std::ifstream input {input_file_argument, std::ios::binary};
    if (not input.is_open())
        fatal("Failed to open input file.");

    // Get the file size.
    input.seekg(0, std::ios::end);
    std::size_t size = input.tellg();
    input.seekg(0, std::ios::beg);

    // Hmm... isn't this what mmap is for?
    char file_data[size];
    input.read(file_data, size);

    input.close();

    std::vector<GBTile> tileset;

    for (int i = 0; i < size; i += 16)
        tileset.push_back(&file_data[i]);

    char rawtile_data[tileset.size()];
    std::memset(rawtile_data, -1, sizeof(rawtile_data));
    int cur_metatile_byte = 0;

    // Optimize the tileset.
    std::vector<GBTile> optimized = tileset;
    int cur_tile = 0;
    for (int i = 0; i < tileset.size(); i++) {
        int matches = 0;
        while (rawtile_data[i] != -1)
            i++;
        rawtile_data[i] = cur_tile;
        for (int j = 0; j < tileset.size(); j++) {
            if (i == j)
                continue;
            if (tileset[i] == tileset[j]) {
                if (rawtile_data[j] == -1) {
                    rawtile_data[j] = cur_tile;
                    matches++;
                }
            }
        }
        cur_tile++;
    }

    char metatile_data[tileset.size()];
    for (int y = 0, i = 0; y < sizeof(metatile_data) / metatile_width ; y += 2) {
        for (int x = 0; x < metatile_width; x += 2) {
            metatile_data[i++] = rawtile_data[x     + y       * metatile_width];
            metatile_data[i++] = rawtile_data[x + 1 + y       * metatile_width];
            metatile_data[i++] = rawtile_data[x     + (y + 1) * metatile_width];
            metatile_data[i++] = rawtile_data[x + 1 + (y + 1) * metatile_width];
        }
    }

    if (output_tileset_argument.length() > 0) {
        std::ofstream output(output_tileset_argument, std::ios::binary);

        if (not output.is_open())
            fatal("Failed to open output tileset file.");

        for (auto& i : optimized)
            output.write(i.data, 16);

        output.close();
    }

    std::ofstream output(output_data_argument);

    if (not output.is_open())
        fatal("Failed to open output assembly file.");

    output << "; Metatile data produced by metamaker; written by Eievui.\n";
    for (int i = 0; i < sizeof(metatile_data);) {
        output << "    ; Metatile ID: " << i / 4 << "\n";
        output << "    db " << (unsigned) metatile_data[i++] + vram_offset;
        output << ", " << (unsigned) metatile_data[i++] + vram_offset << "\n";
        output << "    db " << (unsigned) metatile_data[i++] + vram_offset;
        output << ", " << (unsigned) metatile_data[i++] + vram_offset << "\n";
    }

    output.close();

}