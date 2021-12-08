using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;

namespace PNGtoBitmap
{
    class Program
    {
        class Tile : IEquatable<Tile>
        {
            public List<string> Bitmap = new List<string>();
            public List<Color> Colors = new List<Color>();
            public string Filename { get; }

            public Tile(string name)
            {
                Filename = name;
            }

            public bool Equals(Tile other)
            {
                return this.Bitmap.SequenceEqual(other.Bitmap) && this.Colors.SequenceEqual(other.Colors);
            }
        }

        static readonly string basePath = "../../../../../../";
        static readonly string hardwarePath  = $"{basePath}hardware";
        static void Main()
        {
            // Get the maximum bits for pixel from the colors per tile
            int colorsPerTile = 8;
            int bitsPerPixel = (int)Math.Ceiling(Math.Log2(colorsPerTile));

            // Initialize list to keep track of palette colors
            List<Color> palette = new List<Color>();
            palette.Insert(0, Color.FromArgb(255, 150, 250, 50));

            // Generate tile_rom, map_rom, and the bulk of palette
            palette = ReadSprites("map", colorsPerTile, bitsPerPixel, palette, 16, 16, false);

            // Generate money_rom, car_rom, player_rom, and sprite_table (for text and winner sprites)
            palette = ReadSprites("money", colorsPerTile, bitsPerPixel, palette, 26, 28, false);
            palette = ReadSprites("car", colorsPerTile, bitsPerPixel, palette, 48, 26, true);
            palette = ReadSprites("player", colorsPerTile, bitsPerPixel, palette, 32, 32, true);
            //palette = ReadSprites(colorsPerTile, bitsPerPixel, palette);

            // Print palette_rom
            PrintPaletteRom(palette, 64);
        }

        static List<Color> ReadSprites(string name, int colorsPerTile, int bitsPerPixel, List<Color> palette, int tileWidth, int tileHeight, bool canOverlap)
        {
            Console.WriteLine($"\n<--- READING {name.ToUpper()} FILES --->");

            // Initialize list and 2d array to track the tiles and their corresponding colors
            List<Tile> tiles = new List<Tile>();
            Dictionary<string, List<int>> tileMaps = new Dictionary<string, List<int>>();
            int invalidTiles = 0;
            string invalid = "";

            // Attempt to process the images
            var files = Directory.GetFiles($"assets/{name}");
            if (files.Count() > 0)
            {
                foreach (var file in files)
                {
                    string fileName = file[(file.LastIndexOf('/') + 1)..];
                    string invalidTemp = $"\n        {fileName}: ";
                    List<int> tileMap = new List<int>();

                    // Attempt to retrieve the image
                    var image = new Bitmap(file, true);

                    // Loop through the image pixels to get colors and bitmaps per tile
                    int tilesX = image.Width / tileWidth;
                    int tilesY = image.Height / tileHeight;
                    for (int tileY = 0; tileY < tilesY; tileY++)
                    {
                        for (int tileX = 0; tileX < tilesX; tileX++)
                        {
                            Tile currTile = new Tile(fileName);
                            for (int y = 0; y < tileHeight; y++)
                            {
                                string bitmap = $"{bitsPerPixel * tileWidth}'b";
                                for (int x = 0; x < tileWidth; x++)
                                {
                                    // Get the color of the current pixel and add it to our tile's list if it isnt there already
                                    Color pixelColor = image.GetPixel(tileWidth * tileX + x, tileHeight * tileY + y);
                                    if (!currTile.Colors.Contains(pixelColor))
                                        currTile.Colors.Add(pixelColor);

                                    // Convert color index to binary and pad with 0s if its less than the correct number of bits
                                    bitmap += Convert.ToString(currTile.Colors.IndexOf(pixelColor), 2).PadLeft(bitsPerPixel, '0');
                                }
                                currTile.Bitmap.Add(bitmap);
                            }
                            int tileIdx = tiles.IndexOf(currTile);
                            if (tileIdx == -1)
                            {
                                if (currTile.Colors.Count <= colorsPerTile)
                                {
                                    tileIdx = tiles.Count;
                                    tiles.Add(currTile);
                                    palette = palette.Union(currTile.Colors).ToList();
                                }
                                else
                                {
                                    invalidTemp += $"({tileX},{tileY}), ";
                                    invalidTiles++;
                                }
                            }
                            tileMap.Add(tileIdx);
                        }
                    }

                    if (invalidTemp.Contains(","))
                        invalid += invalidTemp;

                    tileMaps.Add(fileName,tileMap);
                }

                // Display results to console
                int tileBits = (int)Math.Ceiling(Math.Log2(tiles.Count));
                int colorBits = (int)Math.Ceiling(Math.Log2(palette.Count));
                Console.WriteLine($"Valid Tile Count: {tiles.Count}");
                Console.WriteLine($"    {colorsPerTile} Color Tiles: {tileBits}-bit index");
                Console.WriteLine($"Invalid Tile Count: {invalidTiles}");
                Console.WriteLine($"    Affected Tiles: {(invalidTiles == 0 ? "N/A" : invalid[0..^2])}");
                Console.WriteLine($"Palette Color Count: {palette.Count} ({colorBits}-bit index)");
                Console.WriteLine("\nPress any key to generate the output files.");
                Console.ReadKey();

                string data = "";
                int totalMaps = 0;
                foreach (var tileMap in tileMaps)
                {
                    data += $"\n\n        // <--- FILE: {tileMap.Key.ToUpper()} --->\n";
                    for (int i = 0; i < tileMap.Value.Count; i++)
                    {
                        data += $"\n        //tile {i}\n        {GetVRAM(tileMap.Value[i], tiles, palette)},";
                        totalMaps++;
                    }
                }

                string bitmaps = "";
                string lastFileName = "";
                for (int i = 0; i < tiles.Count; i++)
                {
                    var tile = tiles[i];
                    if (lastFileName != tile.Filename)
                    {
                        bitmaps += $"\n\n        // <--- FILE: {tile.Filename.ToUpper()} --->\n";
                        lastFileName = tile.Filename;
                    }
                    bitmaps += $"\n        //tile {i}, VRAM {GetVRAM(i, tiles, palette)}\n        {string.Join(",\n        ", tile.Bitmap)},";
                }

                // Print tile bitmaps to rom
                PrintBitmapRom(name, tiles.Count, palette.Count, totalMaps, bitsPerPixel, tileWidth, tileHeight, data[0..^1], bitmaps[0..^1], canOverlap);
            }
            else
                Console.WriteLine($"FAIL: Unable to find any {name} sprites in assets/{name}.");

            Console.WriteLine("\nPress any key to continue.");
            Console.ReadKey();

            return palette;
        }

        static void PrintBitmapRom(string name, int tileCount, int paletteCount, int totalMaps, int bitsPerPixel, int tileWidth, int tileHeight, string data, string bitmaps, bool canOverlap)
        {
            Console.WriteLine($"\n<--- PRINTING {name.ToUpper()} ROM --->");

            // Calculate ROM address width
            int tileBits = (int)Math.Ceiling(Math.Log2(totalMaps));
            int tilesWidth = (int)Math.Ceiling(Math.Log2(tileCount));
            int paletteBits = (int)Math.Ceiling(Math.Log2(paletteCount));
            int pixelXBits = (int)Math.Ceiling(Math.Log2(tileWidth));
            int pixelYBits = (int)Math.Ceiling(Math.Log2(tileHeight));
            int dataWidth = tilesWidth + paletteBits * 8;
            int bitmapWidth = bitsPerPixel * tileWidth;
            int itemCount = tileCount * tileHeight;
            int addrWidth = (int)Math.Ceiling(Math.Log2(itemCount));

            // Delete file if it exists and output the header data
            if (File.Exists($"{hardwarePath}/{name}_rom.sv"))
                File.Delete($"{hardwarePath}/{name}_rom.sv");
            File.AppendAllText($"{hardwarePath}/{name}_rom.sv", $"module {name}_rom (" +
                                                    $"\n    input  logic [{tileBits - 1}:0]  Tile,{(canOverlap ? " PriTile" : "")}" +
                                                    $"\n    input  logic [{pixelXBits - 1}:0] PixelX,{(canOverlap ? " PriPixelX" : "")}" +
                                                    $"\n    input  logic [{pixelYBits - 1}:0] PixelY,{(canOverlap ? " PriPixelY" : "")}" +
                                                    $"\n    output logic [{paletteBits - 1}:0]  Data" +
                                                    $"\n);\n" +
                                                    $"\n    logic [{dataWidth - 1}:0] data;" +
                                                    $"\n    logic [{addrWidth - 1}:0] bitmapIdx;" +
                                                    $"\n    logic [{bitmapWidth - 1}:0] bitmap;" +
                                                    $"\n    logic [{bitsPerPixel - 1}:0]  color;\n" +
                                                    $"\n    localparam bit [{dataWidth - 1}:0] DATA [{totalMaps}] = " + "'{" +
                                                    $"\n{data}\n    " + 
                                                    "\n    };\n" +
                                                    $"\n    localparam bit [{bitmapWidth - 1}:0] BITMAPS [{itemCount}] = " + "'{" +
                                                    $"\n{bitmaps}\n    " + 
                                                    "\n    };\n" +
                                                    $"\n    always_comb" +
                                                    $"\n    begin" +
                                                    $"\n        data      = DATA[Tile];" +
                                                    $"\n        bitmapIdx = {tileHeight} * data[{tilesWidth - 1}:0] + PixelY;" +
                                                    $"\n        bitmap    = BITMAPS[bitmapIdx];" +
                                                    $"\n        color     = bitmap[{bitsPerPixel}*({tileWidth - 1}-PixelX) +: {bitsPerPixel}];" +
                                                    $"\n        Data      = data[{paletteBits}*color+{tilesWidth} +: {paletteBits}];" +
                                                    $"\n    end\n" +
                                                    "\nendmodule\n");

            Console.WriteLine($"PASS: Printed all tiles to hardware/{name}_rom.sv");
        }

        static string GetVRAM(int tileIdx, List<Tile> tiles, List<Color> palette)
        {
            int tileBits = (int)Math.Ceiling(Math.Log2(tiles.Count));
            int colorBits = (int)Math.Ceiling(Math.Log2(palette.Count));
            int dataWidth = tileBits + colorBits * 8;

            string data = Convert.ToString(tileIdx, 2).PadLeft(tileBits, '0'); //first, store the tile index in data
            if (tileIdx > -1)
            {
                var colors = tiles[tileIdx].Colors;
                foreach (var color in colors)
                    data = $"{Convert.ToString(palette.IndexOf(color), 2).PadLeft(colorBits, '0')}{data}"; //then, store each color index
                data = data.PadLeft(dataWidth, '0'); //pad left to fill the unused bits with 0s
            }
            else
                data = $"{dataWidth}'b".PadLeft(dataWidth, '0'); //if invalid tile, just set it all to 0s

            return $"{dataWidth}'b{data}";
        }

        static void PrintPaletteRom(List<Color> palette, int maxColors)
        {
            Console.WriteLine("\n<--- PRINTING PALETTE ROM --->");
            if (palette.Count <= maxColors)
            {
                // Concatenate all palette colors to a single string
                string print = "";
                for (int i = 0; i < palette.Count; i++)
                {
                    var color = palette[i];
                    string data = Convert.ToString(color.ToArgb(), 2)[8..].PadLeft(24, '0');
                    if (i < palette.Count - 1) //only append a comma if this is not the last one
                        data += ",";
                    else
                        data += " ";
                    print += $"\n        24'b{data} //RGB({color.R},{color.G},{color.B})";
                }

                // Calculate ROM address width
                int addrWidth = (int)Math.Ceiling(Math.Log2(palette.Count));

                // Delete file if it exists and output the header data
                if (File.Exists($"{hardwarePath}/palette_rom.sv"))
                    File.Delete($"{hardwarePath}/palette_rom.sv");
                File.AppendAllText($"{hardwarePath}/palette_rom.sv", $"module palette_rom (" +
                                                        $"\n    input  logic [{addrWidth - 1}:0]  Color," +
                                                        $"\n    output logic [23:0] Data" +
                                                        $"\n);\n" +
                                                        $"\n    localparam bit [23:0] ROM [{palette.Count}] = " + "'{" +
                                                        $"\n{print}\n    " +
                                                        "\n    };\n\n    assign Data = ROM[Color];\n" +
                                                        "\nendmodule\n");

                Console.WriteLine($"PASS: Printed the palette to hardware/palette_rom.sv");
            }
            else
                Console.WriteLine($"FAIL: Expected {maxColors}-color palette at most, found {palette.Count} colors.");
        }
    }
}
