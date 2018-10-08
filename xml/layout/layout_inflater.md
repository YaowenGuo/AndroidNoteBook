(LinearLayout) inflater.inflate(R.layout.item_pinyin_difficult, parent);

**parent 是一个GroupView 类型的父View, 如果在View 中使用同一个xml 文件实例化同一个文件时，同时传入了 parent, 会引起引用的错乱，可能是将这些View 作为一个整体来处理了。而多个 xml 使用的 id 却是一样的。所以有多个xml item 动态添加时，parent 可以为 null 不传入父布局**

```
private View initImageView(LayoutInflater inflater, LinearLayout parent, Pinyin[][] pinyinGroup) {
    View image = null;
    if (pinyinGroup != null) {
        for (Pinyin[] pinyins: pinyinGroup ) {
            image = inflater.inflate(R.layout.item_pinyin_image_compare, null);
            if (pinyins.length > 0) {
                TextView leftText = image.findViewById(R.id.left_text_tv);
                ImageView leftImage = image.findViewById(R.id.left_image_iv);
                leftText.setText(pinyins[0].getPinyin());
//                    leftImage.setImageResource();
            }
            if (pinyins.length > 1) {
                TextView rightText = image.findViewById(R.id.right_text_tv);
                ImageView rightImage = image.findViewById(R.id.right_image_iv);
                rightText.setText(pinyins[1].getPinyin());
//                    rightImage.setImageResource();
            }
            parent.addView(image);
        }
    }

    return image;
}
```
