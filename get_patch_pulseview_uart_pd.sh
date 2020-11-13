#!/usr/bin/env bash

# Note this is a bash script; you can run it under MSYS2 in Windows 10

# get the original UART protocol decoder for Pulseview:

wget https://raw.githubusercontent.com/sigrokproject/libsigrokdecode/e144452/decoders/uart/pd.py

# this script will patch the original pd.py, and add a rough support for two stop bits 
# (not tested extensively, bugs are to be expected)
# after this file has been patched, you'll get a patched pd.py of the UART decoder in this directory;
# just use that to replace (copy over) the installed pd.py of the UART decoder in:
# C:\Program Files (x86)\sigrok\PulseView\share\libsigrokdecode\decoders\uart\pd.py

# save the patch:

cat > pv_uart_pd.patch <<'EOF'
--- pd.py       2020-10-22 23:58:36.000000000 +0200
+++ pd.py       2020-11-12 09:03:04.186320800 +0100
@@ -114,7 +114,7 @@
         {'id': 'parity', 'desc': 'Parity', 'default': 'none',
             'values': ('none', 'odd', 'even', 'zero', 'one', 'ignore')},
         {'id': 'stop_bits', 'desc': 'Stop bits', 'default': 1.0,
-            'values': (0.0, 0.5, 1.0, 1.5)},
+            'values': (0.0, 0.5, 1.0, 1.5, 2.0)},
         {'id': 'bit_order', 'desc': 'Bit order', 'default': 'lsb-first',
             'values': ('lsb-first', 'msb-first')},
         {'id': 'format', 'desc': 'Data format', 'default': 'hex',
@@ -212,6 +212,7 @@
         self.datavalue = [0, 0]
         self.paritybit = [-1, -1]
         self.stopbit1 = [-1, -1]
+        self.stopbit2 = [-1, -1]
         self.startsample = [-1, -1]
         self.state = ['WAIT FOR START BIT', 'WAIT FOR START BIT']
         self.databits = [[], []]
@@ -405,6 +406,7 @@
     # TODO: Currently only supports 1 stop bit.
     def get_stop_bits(self, rxtx, signal):
         self.stopbit1[rxtx] = signal
+        #print("get_stop_bits", rxtx, signal)

         # Stop bits must be 1. If not, we report an error.
         if self.stopbit1[rxtx] != 1:
@@ -415,6 +417,35 @@
         self.putp(['STOPBIT', rxtx, self.stopbit1[rxtx]])
         self.putg([Ann.RX_STOP + rxtx, ['Stop bit', 'Stop', 'T']])

+        if self.options['stop_bits'] == 2:
+            ## Pass the complete UART frame to upper layers.
+            #es = self.samplenum + ceil(self.bit_width / 2.0)
+            #self.putpse(self.frame_start[rxtx], es, ['FRAME', rxtx,
+            #    (self.datavalue[rxtx], self.frame_valid[rxtx])])
+
+            self.state[rxtx] = 'GET STOP BITS2'
+        else:
+          # Pass the complete UART frame to upper layers.
+          es = self.samplenum + ceil(self.bit_width / 2.0)
+          self.putpse(self.frame_start[rxtx], es, ['FRAME', rxtx,
+              (self.datavalue[rxtx], self.frame_valid[rxtx])])
+
+          self.state[rxtx] = 'WAIT FOR START BIT'
+          self.idle_start[rxtx] = self.frame_start[rxtx] + self.frame_len_sample_count
+
+    def get_stop_bits2(self, rxtx, signal):
+        self.stopbit2[rxtx] = signal
+        #print("get_stop_bits2", rxtx, signal)
+
+        # Stop bits must be 1. If not, we report an error.
+        if self.stopbit2[rxtx] != 1:
+            self.putp(['INVALID STOPBIT', rxtx, self.stopbit2[rxtx]])
+            self.putg([Ann.RX_WARN + rxtx, ['Frame error', 'Frame err', 'FE']])
+            self.frame_valid[rxtx] = False
+
+        self.putp(['STOPBIT2', rxtx, self.stopbit2[rxtx]])
+        self.putg([Ann.RX_STOP + rxtx, ['Stop bit2', 'Stop', 'T']])
+
         # Pass the complete UART frame to upper layers.
         es = self.samplenum + ceil(self.bit_width / 2.0)
         self.putpse(self.frame_start[rxtx], es, ['FRAME', rxtx,
@@ -423,6 +454,7 @@
         self.state[rxtx] = 'WAIT FOR START BIT'
         self.idle_start[rxtx] = self.frame_start[rxtx] + self.frame_len_sample_count

+
     def handle_break(self, rxtx):
         self.putpse(self.frame_start[rxtx], self.samplenum,
                 ['BREAK', rxtx, 0])
@@ -446,7 +478,11 @@
         elif state == 'GET STOP BITS':
             bitnum = 1 + self.options['data_bits']
             bitnum += 0 if self.options['parity'] == 'none' else 1
+        elif state == 'GET STOP BITS2':
+            bitnum = self.options['data_bits'] + int(self.options['stop_bits'])
+            bitnum += 0 if self.options['parity'] == 'none' else 1
         want_num = ceil(self.get_sample_point(rxtx, bitnum))
+        #print("state '{}' bitnum {} want_num {}".format(state, bitnum, want_num))
         return {'skip': want_num - self.samplenum}

     def get_idle_cond(self, rxtx, inv):
@@ -476,6 +512,8 @@
             self.get_parity_bit(rxtx, signal)
         elif state == 'GET STOP BITS':
             self.get_stop_bits(rxtx, signal)
+        elif state == 'GET STOP BITS2':
+            self.get_stop_bits2(rxtx, signal)

     def inspect_edge(self, rxtx, signal, inv):
         # Inspect edges, independently from traffic, to detect break conditions.

EOF

# apply the patch

patch <pv_uart_pd.patch

# done - now the pd.py file in this directory is patch; just copy it over:
# C:\Program Files (x86)\sigrok\PulseView\share\libsigrokdecode\decoders\uart\pd.py
# ... and then restart PulseView

