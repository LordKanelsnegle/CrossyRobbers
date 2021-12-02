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
            public string[] Bitmap = new string[16];
            public List<Color> Colors = new List<Color>();

            public bool Equals(Tile other)
            {
                return this.Bitmap.SequenceEqual(other.Bitmap) && this.Colors.SequenceEqual(other.Colors);
            }
        }

        static readonly string basePath = "../../../../../../";
        static readonly string hardwarePath  = $"{basePath}hardware";
        static void Main()
        {
            List<Color> palette = new List<Color>();
            ReadMap(palette);     // Fully implemented and functional. Generates all ROM files.
            ReadSprites(palette); // WIP - will process all sprites to produce a sprite table.
        }
        static void ReadSprites(List<Color> palette)
        {
            Console.WriteLine($"<--- READING MAP FILES --->");

            // Initialize list and 2d array to track the tiles and their corresponding colors
            List<Tile> tiles = new List<Tile>();
            List<int> invalidTiles = new List<int>();
            int[] tileMap = new int[40 * 30];

            // Get the maximum bits for pixel from the colors per tile
            int colorsPerTile = 8;
            int bitsPerPixel = (int)Math.Ceiling(Math.Log2(colorsPerTile));

            // Attempt to process the image
            try
            {
                // Attempt to retrieve the image
                var image = new Bitmap("assets/map.png", true);

                if (image.Width == 640 && image.Height == 480)
                {
                    // Loop through the image pixels to get colors and bitmaps per tile
                    for (int tileY = 0; tileY < 30; tileY++)
                    {

                        for (int tileX = 0; tileX < 40; tileX++)
                        {
                            Tile currTile = new Tile();
                            for (int y = 0; y < 16; y++)
                            {
                                string bitmap = $"{bitsPerPixel * 16}'b";
                                for (int x = 0; x < 16; x++)
                                {
                                    // Get the color of the current pixel and add it to our tile's list if it isnt there already
                                    Color pixelColor = image.GetPixel(16 * tileX + x, 16 * tileY + y);
                                    if (!currTile.Colors.Contains(pixelColor))
                                        currTile.Colors.Add(pixelColor);

                                    // Convert color index to binary and pad with 0s if its less than the correct number of bits
                                    bitmap += Convert.ToString(currTile.Colors.IndexOf(pixelColor), 2).PadLeft(bitsPerPixel, '0');
                                }
                                currTile.Bitmap[y] = bitmap;
                            }
                            int mapIdx = 40 * tileY + tileX;
                            int tileIdx = tiles.IndexOf(currTile);
                            if (tileIdx == -1)
                            {
                                if (currTile.Colors.Count <= colorsPerTile)
                                {
                                    tileIdx = tiles.Count;
                                    tiles.Add(currTile);
                                }
                                else
                                    invalidTiles.Add(mapIdx);
                            }
                            tileMap[mapIdx] = tileIdx;
                        }
                    }

                    // Update the color palette from the valid tiles
                    palette.AddRange(tiles.SelectMany(t => t.Colors).Distinct());
                    // Make sure color at index 0 is black, for error tiles
                    palette.Remove(Color.FromArgb(255, 0, 0, 0)); //cant use Color.Black because it has "named" field
                    palette.Insert(0, Color.FromArgb(255, 0, 0, 0));
                }
                else
                    Console.WriteLine("FAIL: Input map is not 640x480.");
            }
            catch (ArgumentException) { Console.WriteLine("FAIL: Unable to find map.png."); }

            // Display results to console
            int tileBits = (int)Math.Ceiling(Math.Log2(tiles.Count));
            int colorBits = (int)Math.Ceiling(Math.Log2(palette.Count));
            string invalid = "";
            foreach (int idx in invalidTiles)
                invalid += $"({idx % 40},{idx / 40}), ";
            Console.WriteLine($"Valid Tile Count: {tiles.Count}");
            Console.WriteLine($"    {colorsPerTile} Color Tiles: {tileBits}-bit index");
            Console.WriteLine($"Invalid Tile Count: {invalidTiles.Count}");
            Console.WriteLine($"    Affected Tiles: {(invalid == "" ? "N/A" : invalid[0..^2])}");
            Console.WriteLine($"Palette Color Count: {palette.Count} ({colorBits}-bit index)");
            Console.WriteLine("\nPress any key to generate the output files.");
            Console.ReadKey();

            // Print map_rom
            PrintMapRom(tileMap, tiles, palette, tileBits, colorBits);

            // Print tile_rom
            PrintTileRom(tiles, bitsPerPixel);

            // Print palette_rom
            PrintPaletteRom(palette, 64);

            Console.WriteLine("\nPress any key to continue.");
            Console.ReadKey();
        }

        static void ReadMap(List<Color> palette)
        {
            Console.WriteLine($"<--- READING MAP FILE --->");

            // Initialize list and 2d array to track the tiles and their corresponding colors
            List<Tile> tiles = new List<Tile>();
            List<int> invalidTiles = new List<int>();
            int[] tileMap = new int[40 * 30];

            // Get the maximum bits for pixel from the colors per tile
            int colorsPerTile = 8;
            int bitsPerPixel = (int)Math.Ceiling(Math.Log2(colorsPerTile));

            // Attempt to process the image
            try
            {
                // Attempt to retrieve the image
                var image = new Bitmap("assets/map.png", true);

                if (image.Width == 640 && image.Height == 480)
                {
                    // Loop through the image pixels to get colors and bitmaps per tile
                    for (int tileY = 0; tileY < 30; tileY++)
                    {

                        for (int tileX = 0; tileX < 40; tileX++)
                        {
                            Tile currTile = new Tile();
                            for (int y = 0; y < 16; y++)
                            {
                                string bitmap = $"{bitsPerPixel * 16}'b";
                                for (int x = 0; x < 16; x++)
                                {
                                    // Get the color of the current pixel and add it to our tile's list if it isnt there already
                                    Color pixelColor = image.GetPixel(16 * tileX + x, 16 * tileY + y);
                                    if (!currTile.Colors.Contains(pixelColor))
                                        currTile.Colors.Add(pixelColor);

                                    // Convert color index to binary and pad with 0s if its less than the correct number of bits
                                    bitmap += Convert.ToString(currTile.Colors.IndexOf(pixelColor), 2).PadLeft(bitsPerPixel, '0');
                                }
                                currTile.Bitmap[y] = bitmap;
                            }
                            int mapIdx = 40 * tileY + tileX;
                            int tileIdx = tiles.IndexOf(currTile);
                            if (tileIdx == -1)
                            {
                                if (currTile.Colors.Count <= colorsPerTile)
                                {
                                    tileIdx = tiles.Count;
                                    tiles.Add(currTile);
                                }
                                else
                                    invalidTiles.Add(mapIdx);
                            }
                            tileMap[mapIdx] = tileIdx;
                        }
                    }

                    // Update the color palette from the valid tiles
                    palette.AddRange(tiles.SelectMany(t => t.Colors).Distinct());
                    // Make sure color at index 0 is black, for error tiles
                    palette.Remove(Color.FromArgb(255,0,0,0)); //cant use Color.Black because it has "named" field
                    palette.Insert(0, Color.FromArgb(255, 0, 0, 0));
                }
                else
                    Console.WriteLine("FAIL: Input map is not 640x480.");
            }
            catch (ArgumentException) { Console.WriteLine("FAIL: Unable to find map.png."); }

            // Display results to console
            int tileBits = (int)Math.Ceiling(Math.Log2(tiles.Count));
            int colorBits = (int)Math.Ceiling(Math.Log2(palette.Count));
            string invalid = "";
            foreach (int idx in invalidTiles)
                invalid += $"({idx % 40},{idx / 40}), ";
            Console.WriteLine($"Valid Tile Count: {tiles.Count}");
            Console.WriteLine($"    {colorsPerTile} Color Tiles: {tileBits}-bit index");
            Console.WriteLine($"Invalid Tile Count: {invalidTiles.Count}");
            Console.WriteLine($"    Affected Tiles: {(invalid == "" ? "N/A" : invalid[0..^2])}");
            Console.WriteLine($"Palette Color Count: {palette.Count} ({colorBits}-bit index)");
            Console.WriteLine("\nPress any key to generate the output files.");
            Console.ReadKey();

            // Print map_rom
            PrintMapRom(tileMap, tiles, palette, tileBits, colorBits);

            // Print tile_rom
            PrintTileRom(tiles, bitsPerPixel);

            // Print palette_rom
            PrintPaletteRom(palette, 64);

            Console.WriteLine("\nPress any key to continue.");
            Console.ReadKey();
        }

        static void PrintMapRom(int[] tileMap, List<Tile> tiles, List<Color> palette, int tileBits, int colorBits)
        {
            int dataWidth = tileBits + colorBits * 8;
            Console.WriteLine("\n<--- PRINTING MAP ROM --->");

            // Prepare the output file
            PrepareRomFile("map", tileMap.Length, dataWidth);
            
            // Iterate over the tile map
            for (int i = 0; i < tileMap.Length; i++)
            {
                int tileIdx = tileMap[i];
                string data = Convert.ToString(tileIdx, 2).PadLeft(tileBits, '0'); //first, store the tile index in data
                if (tileIdx > -1)
                {
                    var colors = tiles[tileIdx].Colors;
                    foreach (var color in colors)
                        data = $"{Convert.ToString(palette.IndexOf(color), 2).PadLeft(colorBits, '0')}{data}"; //then, store each color index
                    data = data.PadLeft(dataWidth, '0'); //pad left to fill the unused bits with 0s
                }
                else
                    data = $"{dataWidth}'b".PadLeft(dataWidth, '0'); //if invalid tile, just set it all to 0s (black square)
                if (i < tileMap.Length - 1) //only append a comma if this is not the last one
                    data += ",";
                File.AppendAllText($"{hardwarePath}/map_rom.sv", $"\n        //Tile {i} ({(i % 40)},{(i / 40)})" + 
                                                            $"\n        {dataWidth}'b{data}");
            }
            File.AppendAllText($"{hardwarePath}/map_rom.sv", "\n    };\n\n    assign data = ROM[addr];\n\nendmodule");
            Console.WriteLine($"PASS: Printed tile map to {hardwarePath}/map_rom.sv");
        }

        static void PrintTileRom(List<Tile> tiles, int bitsPerPixel)
        {
            Console.WriteLine("\n<--- PRINTING TILE ROM --->");

            // Prepare the output file
            PrepareRomFile("tile", tiles.Count*16, bitsPerPixel*16);

            // Output all bitmaps (with their corresponding indices) to tile_rom
            for (int i = 0; i < tiles.Count; i++)
            {
                string comma = "";
                if (i < tiles.Count - 1) //only append a comma if this is not the last one
                    comma += ",";
                File.AppendAllText($"{hardwarePath}/tile_rom.sv", $"\n        //tile_code {i}" +
                                                          $"\n        {string.Join(",\n        ", tiles[i].Bitmap)}{comma}");
            }
            File.AppendAllText($"{hardwarePath}/tile_rom.sv", "\n    };\n\n    assign data = ROM[addr];\n\nendmodule");
            Console.WriteLine($"PASS: Printed all tiles to {hardwarePath}/tile_rom.sv");
        }

        static void PrintPaletteRom(List<Color> palette, int maxColors)
        {
            Console.WriteLine("\n<--- PRINTING PALETTE ROM --->");
            if (palette.Count <= maxColors)
            {
                // Prepare the output file
                PrepareRomFile("palette", palette.Count, 24);

                // Output all palette colors to palette_rom
                for (int i = 0; i < palette.Count; i++)
                {
                    var color = palette[i];
                    string data = Convert.ToString(color.ToArgb(), 2)[8..].PadLeft(24, '0');
                    if (i < palette.Count - 1) //only append a comma if this is not the last one
                        data += ",";
                    File.AppendAllText($"{hardwarePath}/palette_rom.sv", $"\n        24'b{data} //RGB({color.R},{color.G},{color.B})");
                }
                File.AppendAllText($"{hardwarePath}/palette_rom.sv", "\n    };\n\n    assign data = ROM[addr];\n\nendmodule");

                Console.WriteLine($"PASS: Printed the palette to {hardwarePath}/palette_rom.sv");
            }
            else
                Console.WriteLine($"FAIL: Expected {maxColors}-color palette at most, found {palette.Count} colors.");
        }

        static void PrepareRomFile(string rom, int itemCount, int dataBits)
        {
            // Calculate ROM address width
            int addrWidth = (int)Math.Ceiling(Math.Log2(itemCount));

            // Delete file if it exists and output the header data
            if (File.Exists($"{hardwarePath}/{rom}_rom.sv"))
                File.Delete($"{hardwarePath}/{rom}_rom.sv");
            File.AppendAllText($"{hardwarePath}/{rom}_rom.sv", $"module {rom}_rom (" +
                                                    $"\n    input logic [{addrWidth-1}:0] addr," +
                                                    $"\n    output logic [{dataBits-1}:0] data" +
                                                    $"\n);\n" +
                                                    $"\n    parameter bit [{dataBits-1}:0] ROM [{itemCount}] = " + "'{");
        }
    }
}
