import math
import wave
import struct
import os

def generate_beep(filename, freq, duration_ms, volume=0.5):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        
        for i in range(num_samples):
            # Attack and decay to prevent popping
            envelope = 1.0
            if i < 441: # 10ms attack
                envelope = i / 441.0
            elif i > num_samples - 441: # 10ms decay
                envelope = (num_samples - i) / 441.0
                
            sample = int(32767 * volume * envelope * math.sin(2 * math.pi * freq * i / sample_rate))
            f.writeframes(struct.pack('<h', sample))

os.makedirs('assets/sounds', exist_ok=True)
generate_beep('assets/sounds/high_beep.wav', 880.0, 50)
generate_beep('assets/sounds/low_beep.wav', 440.0, 50)
