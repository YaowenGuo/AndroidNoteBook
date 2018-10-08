
## 扇形中间位置限制文字计算
```
    private void drawPieChart(Canvas canvas) {

        int centerX = getWidth() / 2;
        int centerY = getHeight() / 2;
        mPaint.setColor(mWrongColor);
        mRectF.set(centerX - mRadius, centerY - mRadius, centerX + mRadius, centerY + mRadius);
        float wrongPercent = mWrongPercent / 100f;
        canvas.drawArc(mRectF, mStartAngle, wrongPercent * 360 * mAnimaProgress, true, mPaint);


        if (!mAnimatorEnd) return;

        float textAngle = wrongPercent * (float) Math.PI + mStartRad;

        mPaint.setColor(Color.WHITE);
        mPaint.setTextAlign(Paint.Align.CENTER);
        mPaint.setTextSize(mTextSize);
        mPaint.setFakeBoldText(true);
        float startX, startY;
        if (mWrongPercent > 0) {
            startX = (float) (centerX + mRadius / 2 * Math.cos(textAngle));
            startY = (float) (centerY + mRadius / 2 * Math.sin(textAngle)) + mTextSize / 2;

            canvas.drawText(mWrongPercent + "", startX, startY, mPaint);
        }

        textAngle = (float) Math.PI * (1 + wrongPercent) + mStartRad;
        startX = (float) (centerX + mRadius / 2 * Math.cos(textAngle));
        startY = (float) (centerY + mRadius / 2 * Math.sin(textAngle)) + mTextSize / 2;

        canvas.drawText((100 - mWrongPercent) + "", startX, startY, mPaint);
    }

```
