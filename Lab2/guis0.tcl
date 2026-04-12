set DESIGN bound_flasher

read_libs  "../LIB/slow.lib ../LIB/pll.lib  ../LIB/CDK_S128x16.lib  ../LIB/CDK_S256x16.lib  ../LIB/CDK_R512x16.lib "

read_physical -lef " ../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef ../LEF/pll.lef   ../LEF/CDK_S128x16.lef  ../LEF/CDK_S256x16.lef ../LEF/CDK_R512x16.lef " 

read_hdl "./outputs_Apr10-09:52:21/bound_flasher_m.v"

elaborate $DESIGN
