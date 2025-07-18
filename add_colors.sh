#!/bin/bash

ASSETS_DIR="Assets.xcassets"

declare -A COLORS
COLORS["PluckrBackground"]="#F8F7F4,#181716"
COLORS["PluckrCard"]="#F3EFE7,#23211D"
COLORS["PluckrAccent"]="#6CA58B,#4B7B5A"
COLORS["PluckrButton"]="#6CA58B,#4B7B5A"
COLORS["PluckrTagGreen"]="#D6EAD7,#2E4731"
COLORS["PluckrTagBeige"]="#F5E9DA,#4B4237"
COLORS["PluckrTagTan"]="#E9D8C3,#3E3322"
COLORS["PluckrTagRed"]="#F8D7DA,#5A2328"
COLORS["PluckrTagYellow"]="#FFF9DB,#4B4420"
COLORS["PluckrTagBlue"]="#D6EAF8,#223A5E"
COLORS["PluckrTagPurple"]="#E5D6F8,#2E235A"
COLORS["PluckrTagTeal"]="#D6F8F3,#235A4B"
COLORS["PluckrTagOrange"]="#FFE5B3,#5A3C23"

hex_to_rgb() {
    hex="${1#"#"}"
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    printf "\"red\" : \"%.3f\", \"green\" : \"%.3f\", \"blue\" : \"%.3f\", \"alpha\" : \"1.0\"" \
        "$(echo \"scale=3; $r/255\" | bc)" \
        "$(echo \"scale=3; $g/255\" | bc)" \
        "$(echo \"scale=3; $b/255\" | bc)"
}

for name in "${!COLORS[@]}"; do
    IFS=',' read -r light dark <<< "${COLORS[$name]}"
    DIR="$ASSETS_DIR/$name.colorset"
    mkdir -p "$DIR"
    cat > "$DIR/Contents.json" <<EOF2
{
  "colors" : [
    {
      "idiom" : "universal",
      "color" : {
        "color-space" : "srgb",
        "components" : { $(hex_to_rgb $light) }
      },
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "light"
        }
      ]
    },
    {
      "idiom" : "universal",
      "color" : {
        "color-space" : "srgb",
        "components" : { $(hex_to_rgb $dark) }
      },
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ]
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF2
    echo "Created $name.colorset"
done
