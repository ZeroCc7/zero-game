# 五系人物与作战宠物待机原图提示词

用途：自己生成 2D 待机 sprite sheet 原图，再用本地脚本后处理为透明 PNG 帧、spritesheet 和 GIF 预览。

参考风格：暗黑国风战棋、古风仙侠、半写实手绘、低饱和、战场单位视角。所有单位都必须背对玩家，朝向画面左上方。

## 通用前缀

每次生成都先使用这一段，再接具体角色描述。

```text
Use the provided reference image only for visual style: dark Chinese fantasy tactical RPG battle unit, semi-realistic hand-painted game art, 3/4 top-down isometric view, dramatic low-key lighting, ancient ruined battlefield mood, muted colors, ornate wuxia costume details, readable small game unit silhouette.

Create a 2D game idle animation sprite sheet, exact 2 rows and 2 columns, 4 frames total.

The unit is seen from behind, back facing the viewer, looking and facing toward the upper-left direction of the image.
The camera sees the character's back and rear-side silhouette, not the face.
The head, torso, feet, weapon, and body orientation all point toward upper-left.
Do not show a frontal face, do not turn toward the viewer, do not face right or down.

The character stays in place, idle breathing only, no walking, no stepping, no side-to-side movement.
Feet/bottom anchor stays exactly fixed in every frame.
Body centerline stays exactly centered in each cell.
Same identity, same scale, same bounding box in all frames.

Solid flat #FF00FF magenta background only.
No text, no labels, no UI, no borders, no frame dividers.
Full body visible, generous magenta margin around the subject.
Nothing crosses cell edges.

The unit should read clearly at small tactical-battle size, like a premium Chinese fantasy turn-based strategy game unit, not a close-up character illustration.
High resolution, sharp details, clean silhouette.
The full sheet should be at least 1536x1536 pixels, each cell about 768x768 pixels.
```

## 五系人物

### 金系人物

```text
A gold-element male wuxia swordsman battle unit, wearing dark bronze and black layered robes with gold trim, rear-visible shoulder armor, long black hair flowing down the back, holding a heavy golden straight sword angled toward the upper-left. Subtle golden sword aura and metallic glow close to the body. Calm battle-ready idle pose, noble and stern presence, ancient Chinese fantasy style. Back facing the viewer, facing upper-left.
```

### 木系人物

```text
A wood-element female healer or spirit cultivator battle unit, wearing deep green and ivory flowing Hanfu robes, vine-like jade ornaments, wooden staff held toward the upper-left, long dark hair with leaf hairpins visible from behind. Subtle green life energy close to the hands and staff. Gentle but powerful idle breathing pose, elegant Chinese fantasy tactical RPG unit. Back facing the viewer, facing upper-left.
```

### 水系人物

```text
A water-element male swordsman battle unit, wearing pale blue and white flowing robes, silver-blue belt ornaments, long black hair visible from behind, thin curved sword angled toward the upper-left. Subtle mist and water ribbon aura close to the body, calm cold presence, graceful idle pose, dark wuxia tactical RPG style. Back facing the viewer, facing upper-left.
```

### 火系人物

```text
A fire-element female martial mage battle unit, wearing crimson and black battle robes with dark gold ornaments, long tied hair visible from behind, flame-pattern sleeves, holding a short blade or fire talisman toward the upper-left. Subtle ember glow and small flame aura close to the hands. Fierce idle stance, ancient Chinese fantasy battlefield style. Back facing the viewer, facing upper-left.
```

### 土系人物

```text
An earth-element male guardian warrior battle unit, wearing heavy brown-black armor with stone and bronze plates, broad rear-facing stance, large polearm or heavy blade pointing toward the upper-left, rugged armored silhouette, tied black hair visible from behind. Subtle dust and stone energy close to the feet. Stable defensive idle pose, dark Chinese fantasy tactical RPG unit. Back facing the viewer, facing upper-left.
```

## 五系作战宠物

### 金系宠物

```text
A gold-element armored lion battle pet, compact powerful body, bronze-gold armor plates, sharp mane visible from behind, glowing golden accents, ancient guardian beast design. The lion is rear-facing with its head and body turned toward the upper-left, no frontal face toward the viewer. Subtle metallic aura close to the body, idle breathing pose, 3/4 top-down view, dark Chinese fantasy tactical RPG creature.
```

### 木系宠物

```text
A wood-element deer spirit battle pet, elegant body, jade antlers, moss-green fur, leaf and vine markings, faint green spirit glow. The deer is rear-facing with its head, antlers, and body oriented toward the upper-left, no frontal face toward the viewer. Gentle idle breathing pose, magical but battle-ready, readable silhouette, dark Chinese fantasy tactical RPG creature.
```

### 水系宠物

```text
A water-element fox spirit battle pet, pale blue-white fur, flowing tail visible from behind, misty water aura close to the body, crystalline blue accents. The fox is rear-facing with its head and body oriented toward the upper-left, no frontal face toward the viewer. Calm idle breathing pose, 3/4 top-down tactical RPG style.
```

### 火系宠物

```text
A fire-element wolf battle pet, black and crimson fur, ember cracks along the body, glowing red accents, small flames close to the mane and paws. The wolf is rear-facing with its head and body oriented toward the upper-left, no frontal face toward the viewer. Aggressive idle breathing pose, no large detached flames, dark Chinese fantasy tactical RPG creature.
```

### 土系宠物

```text
An earth-element armored turtle or stone beast battle pet, heavy shell with bronze and stone plates, dark green-brown body, ancient rune details, sturdy low silhouette. The beast is rear-facing with its head and body oriented toward the upper-left, no frontal face toward the viewer. Subtle dust aura close to the feet, defensive idle breathing pose, 3/4 top-down dark fantasy tactical RPG creature.
```

## 后处理建议

生成原图后，建议用较大的 `cell-size`，不要用默认 128。

```powershell
& 'C:\Users\Z\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' `
  C:\Users\Z\.codex\skills\generate2dsprite\scripts\generate2dsprite.py process `
  --input G:\code\zero-game\assets\_sprite_runs\example_idle\raw.png `
  --target asset `
  --mode idle `
  --rows 2 `
  --cols 2 `
  --cell-size 512 `
  --output-dir G:\code\zero-game\assets\_sprite_runs\example_idle\out512 `
  --align bottom `
  --shared-scale `
  --component-mode largest `
  --reject-edge-touch
```

如果原图每格接近 768x768，可以改成：

```text
--cell-size 768
```

