using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;

namespace PNGtoBitmap
{
    class Program
    {
        class Tile
        {
            public int Index { get; }
            public string[] Bitmap = new string[16];
            public List<Color> Colors = new List<Color>();

            public Tile(int index)
            {
                Index = index;
            }
        }

        static void Main(string[] args)
        {
            // Get an input image from the user
            Console.WriteLine("Drag your file into this folder and enter its name (e.g. tiles.png):");
            string file = Console.ReadLine();
            Console.WriteLine();

            try
            {
                // Attempt to retrieve the image
                var image = new Bitmap(file, true);

                // Get an input for the colors per tile
                Console.WriteLine("Enter the number of colors allowed per tile (should be 4 for tiles and 8 for entities):");
                string input = Console.ReadLine();
                Console.WriteLine();

                int colorsPerTile = int.Parse(input);
                if (colorsPerTile == 4 || colorsPerTile == 8)
                {
                    // Initialize list to track the tiles and their corresponding colors
                    List<Tile> Tiles = new List<Tile>();

                    // Get the maximum bits for pixel from the colors per tile
                    int bitsPerPixel = (int)Math.Ceiling(Math.Log2(colorsPerTile));

                    // Loop through the image pixels to get colors and bitmaps per tile
                    string bitmap = "";
                    for (int y = 0; y < image.Height; y++)
                    {
                        for (int x = 0; x < image.Width; x++)
                        {
                            // Convert x,y coordinates into tile coordinates
                            int tileX = x / 16;
                            int tileY = y / 16;
                            int tileIndex = (image.Width / 16) * tileY + tileX;

                            // Get the current tile from our list or add it if it isnt there already
                            Tile currTile = new Tile(tileIndex);
                            if (Tiles.Count > tileIndex)
                                currTile = Tiles[tileIndex];
                            else
                                Tiles.Add(currTile);

                            // Get the color of the current pixel and add it to our tile's list if it isnt there already
                            Color pixelColor = image.GetPixel(x, y);
                            if (!currTile.Colors.Contains(pixelColor))
                                currTile.Colors.Add(pixelColor);

                            int bit = x % 16;
                            if (bit == 0) //reset the bitmap row on every 16th bit
                                bitmap = $"{bitsPerPixel * 16}'b";
                            else if (bit == 15) //save the current bitmap row before it gets reset
                                Tiles[tileIndex].Bitmap[y % 16] = bitmap + ",";

                            // Convert color index to binary and pad with 0s if its less than the correct number of bits
                            bitmap += Convert.ToString(currTile.Colors.IndexOf(pixelColor), 2).PadLeft(bitsPerPixel, '0');

                            // Update the current tile
                            Tiles[tileIndex] = currTile;
                        }
                    }

                    if (Tiles.Count > 0)
                    {
                        // Check for invalid tiles
                        var invalidTiles = Tiles.Where(t => t.Colors.Count > colorsPerTile);
                        Console.WriteLine($"Total Tile Count: {Tiles.Count}\nMax Colors Per Tile: {colorsPerTile}\n");
                        if (invalidTiles.Count() > 0)
                            Console.WriteLine($"FAIL: Found {invalidTiles.Count()} tiles with more than {colorsPerTile} colors: " +
                                $"{string.Join(", ", invalidTiles.Select(t => t.Index))}");
                        else
                        {
                            // If no invalid tiles are found, pass a success
                            Console.WriteLine($"PASS: All tiles have {colorsPerTile} colors or less.");

                            // Delete the output file in preparation for appending to it
                            if (File.Exists("output.txt"))
                                File.Delete("output.txt");

                            // Print all bitmaps (with their corresponding indices) to output.txt
                            List<Color> palette = new List<Color>();
                            for (int i = 0; i < Tiles.Count; i++)
                            {
                                List<string> indices = new List<string>();
                                foreach (var color in Tiles[i].Colors)
                                {
                                    if (!palette.Contains(color))
                                        palette.Add(color);
                                    indices.Add(Convert.ToString(palette.IndexOf(color),2).PadLeft(5,'0'));
                                }
                                File.AppendAllText("output.txt", $"\n//tile {i}: {string.Join(", ", indices)}\n");
                                File.AppendAllLines("output.txt", Tiles[i].Bitmap);
                            }
                            Console.WriteLine($"PASS: Printed all tiles to output.txt");

                            // Print the palette to the end of output.txt, if there is the correct number of colors
                            if (palette.Count <= 32)
                            {
                                File.AppendAllText("output.txt", "\n\n//PALETTE");
                                foreach (var color in palette)
                                    File.AppendAllText("output.txt", $"\n32'b{Convert.ToString(color.ToArgb(), 2).PadLeft(32, '0')},"); //32 bits per color

                                Console.WriteLine($"PASS: Printed {palette.Count}-color palette to output.txt");
                            } else
                                Console.WriteLine($"FAIL: Expected 32-color palette at most, found {palette.Count} colors.");
                        }
                    }
                    else
                        Console.WriteLine($"No 16x16 tiles found in {input}.");
                }
                else
                    Console.WriteLine($"\"{input}\" is not an acceptable number.");
            }
            catch (ArgumentException) { Console.WriteLine($"Unable to find {file}."); }

            Console.WriteLine($"Press any key to continue.");
            Console.ReadKey();
        }
    }
}
