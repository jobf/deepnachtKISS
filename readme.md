# deepnachtKISS

KISS approach generic 2D game base on haxe lime with peote-view graphics.

demo - https://jobf.github.io/deepnachtKISS/

## Dependencies

haxe https://haxe.org/
lime https://lime.openfl.org/
peote-view https://github.com/maitag/peote-view

## Run it

With dependencies installed, from the root of the repository:

### Web

```terminal
lime test html5
```

### Hashlink

```terminal
lime test hl
```

## About

Simple game base with the bare essentials needed to quickly start prototyping 2D games.

It's a slightly altered implementation of "A simple generic 2D engine" as written about here - https://deepnight.net/tutorials/

### Features

 - Grid based collisions - for level platforms/walls
 - Radius based collisions - for entity interactions
 - Bresenham line of sight - for casting rays through the level
 - No assets, only colored tiles - concentrate on the game
