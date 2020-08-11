
### RecyclerView.Adapter<> 添加监听器和 findViewById 的时机

RecyclerView.Adapter<RecyclerView.ViewHolder>

```Java
// com.fenbi.android.module.jingpinban.home.TaskCardViewHolder


public void bind(PrimeLecture lecture, Task task) {
    viewAccessor.setImage(R.id.task_bg, taskBgRes)
                .setText(R.id.task_name, task.getTitle())
                .setText(R.id.time, task.getSubTitle())
                .setText(R.id.task_start, FormatUtils.formatHourTime(task.getPublishTime()))
                .setText(R.id.task_status, spanUtils.create())
                .setText(R.id.task_desc, task.getSuggest())
                .setClickListener(R.id.card, v -> {
                            addExerciseCallback(task, viewAccessor);
                            RouterUtils.openTask(v.getContext(), lecture.getId(), task, itemView.findViewById(R.id.transition_view));
                        }
                );
    ....
}


// com/fenbi/android/module/jingpinban/detail/ScoreColumnAdapter.java

    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        View itemView = holder.itemView;

        TextView dateText = itemView.findViewById(R.id.date_text);
        View column = itemView.findViewById(R.id.column);
        View columnSelected = itemView.findViewById(R.id.column_selected);
        TextView selectPop = itemView.findViewById(R.id.select_pop);

        ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) itemView.getLayoutParams();
        lp.leftMargin = SizeUtils.dp2px(position == 0 ? 0 : -20);
        itemView.setLayoutParams(lp);
        ...
    }
```

导致的问题：

1. 每次都绑定都 `findViewById` 重新查找 View. ViewHolder 和 Item View 是一一对应的，ListView 的一个优化就是写 ViewHolder 来保存 `findViewById` 获取的 View 引用。RecyclerView 的一个优化就是强制 ViewHolder，简化了判断 ViewHolder。

2. 每次绑定都生成新的 `listener` 对象。浪费对象的创建和 GC 时间。


滑动回收后从新绑定，和 notifyDataSetChange() 方法都会导致从新绑定而导致不必要的性能消耗。


固定写法。

```Java
public class ReportRecyclerAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case ITEM_TYPE_1:
                return new StudyTimeViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.job_daily_report_list_item, parent, false));
            case ITEM_TYPE_2:
            default:
                return new TitleViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.job_daily_report_list_item, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof StudyTimeViewHolder) {
            ((StudyTimeViewHolder) holder).setData((DataType1) dataList.get(position));
        } else if (holder instanceof TitleViewHolder) {
            ((StudyTimeViewHolder) holder).setData((DataType2) dataList.get(position));
        }
        // 也不建议在这里写各个 viewHolder.view.set 的 set 方法。各个 ViewHolder 
    
    }

    static class StudyTimeViewHolder extends RecyclerView.ViewHolder {
        TextView order;
        ...

        public StudyTimeViewHolder(@NonNull View groupView) {
            super(groupView);
            order = groupView.findViewById(R.id.daily_report_item_order);
            ...
            order.setOnClickListener(v -> {
                // 不要使用 getAdapterPosition(), 滑动过快时会返回 -1;
                // 不必使用 itemView.getTag() 就能获取到 position.
                int position = getLayoutPosition();
                ...
            });
        }

        void setData(DataType data) {
            order.setText(data.getOrder());
            ...
        }

    }
}
```


两处可优化的点

1. RecyclerView.setRecycledViewPool(...) 当多个列表共用同一种 RecyclerView.Adapter 的时候特别使用。 例如多个相同 Tab 的列表页。



2. RecyclerView.hasFixedSize(true) 当 item 的改变，不会导致 RecyclerView 的宽高变化的时候，可以使用，避免 `notifyDataItem/RangeXXXX` 组方法调用的时候，从新测量自身。

```Java

```



