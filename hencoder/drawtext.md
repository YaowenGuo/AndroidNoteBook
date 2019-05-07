# Text

canvas.drawText(text, x, y, paint);

其中坐标 `(x, y)` 是默认是文字的坐下角

canvas.drawTextRun() (带上下文，api23)
canvas.drawTextOnPath() （沿着路径绘制，满足一些特殊需求）

以上绘制不能实现自动换行和到 View 边界自动换行，需要自动换行的可以使用 `StaticLayout` 辅助
如果你需要进行多行文字的绘制，并且对文字的排列和样式没有太复杂的花式要求，那么使用  StaticLayout 就好。想要绘制比较花哨或者类似富文本的样式，就要使用 `canvas.drawText` 边计算边绘制了。

## 字体样式相关的都在 Pain 中

- 大小： setTextSize
- 字体： setTypeface
- 是否使用伪粗体： setFakeBoldText
- 删除线： setStrikeThruText
- 下划线： setUnderlineText
- 倾斜： setTextSkewX
- 缩放： setTextScaleX/Y
- 字符间距： setLetterSpacing
- 对齐： setTextAlign，即 `(x, y)` 坐标中的 x 是文字的左边、中间，还是右边
- 语言地区： setTextLocale （不同地区的同一个字样子可能不一样。）
...


textSize != textHeight

## 文字测量

![](image/text_mesure.jpg)


> Paint

文字的左右和上下边距

- 行距：paint.getFontSpacing()
- ascent / descent： Paint.ascent() 和 Paint.descent()
- 显示范围： getTextBounds(String text, int start, int end, Rect bounds)，紧贴文字可见的边框。
- 文字宽度 measureText, 获取的是字符串的有效宽度，字符显示的间距，其实有字符所占的宽度往往比显示的范围大一些。
- 每个字符的宽度： getTextWidths(String text, float[] widths) 并把结果填入参数 widths.
- breakText(String text, boolean measureForwards, float maxWidth, float[] measuredWidth) 给定宽度显示，测量文字的宽度，并且范围给定宽度能够显示字符的数量。measureForwards 表示文字的测量方向，true 表示由左往右测量；maxWidth 是给出的宽度上限；measuredWidth 是用于接受数据，而不是用于提供数据的：方法测量完成后会把截取的文字宽度（如果宽度没有超限，则为文字总宽度）赋值给 measuredWidth[0]。
- 光标位置： getRunAdvance(CharSequence text, int start, int end, int contextStart, int contextEnd, boolean isRtl, int offset)


> FontMetircs.getFontMetrics()

文字的几条线

- baseline： 不用计算，文字的坐标的位置。 其余几个尺寸都是相对于 baseline 的距离，在 baseline 上方的为负值，下方的为正值。
- scent / descent： 文字的建议限制范围，一般是在这个边界内。他们是相对 baseline 的相对位移
- top / bottom： 字体范围
- leading： 下一行的 top 和 该行的 bottom 之间的距离。


bottom - top + leading 的结果是要大于 getFontSpacing() 的返回值的。
