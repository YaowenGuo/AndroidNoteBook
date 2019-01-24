# API 接口返回数据结构的思考

返回数据结构的讨论已经过去一两周了，这两天看代码有更清晰的认识。可以拿来回顾一下。

> 方式一：

API 返回数据之前一直是以对象不同，通过不同字段来区分的。就是大括号，暂且称为方式一，
```
"data": {
        "token": "...",
        "expires_in": 2592000,
        "user_id": "fca61e32-f22a-11e8-9465-02420a000008",
        "user_info": {...},
        "user_times": {...},
        "levels": [...]
    }
```

> 方式二

直到有新同事提出了新的方案。使用 数组来放置不同对象。。
好处是对顺序有调整有更灵活的适应。添加新的数据类型对原 API 没有影响（这一点老的组织方式一样有，稍后讨论。）。
```
"data": [
            {
            "type": "title",
            "label_name": "Newest"
            ...
            },
            {
             "id": 514,
             "type": "article",
             ...
            }
            ....
     ]

```

## 接收处理

1， 在定义 Bean 类的数量上，两者并没有任何差别。差别主要在根节点数据属性的数量上。
- 方式一每个 bean 类只要定义自己的属性就行了。
  方式二需要额外定义一个类，包含了所有属性值。

比较带来的好处与处理

### 1. 数据类型的类型。

方式1 接收到数据类型，通过现有的映射就能映射为相应的对象。而方式二则不是，只能映射成一个包含所有属性的对象。想要获得不同对象，按照zhaonan 的说法，只要强转就行了。然而事实并不是这么美好。
    - 类型转换的思想是：向上转型（从子类转为父类）是安全的，向下转型是危险的，除非明确知道是子类对象，只是引用是父类的。所以 java 中有 `instanceof` 来用于转型之前先判断。但是，方式二生成的就是父类对象。是判断不出子类的。所以为了区分不同对象，需要再硬编码 new 对象，转换对象。 ***我觉着这个地方是整个方案中最丑陋的部分，也是反对使用这种方案的主要原因***
``` java
    private void updateList(NewArticleBean.Data data) {
        switch (data.type) {
            case "title":
                TitleBean titleBean = new TitleBean();
                titleBean.labelName = data.labelName;
                titleBean.type = data.type;
                itemList.add(titleBean);
                break;
            case "top":
                TopFirstBean topFirstBean = new TopFirstBean();
                topFirstBean.type = data.type;
                topFirstBean.id = data.id;
                topFirstBean.slug = data.slug;
                topFirstBean.title = data.title;
                topFirstBean.metaDesc = data.metaDesc;
                topFirstBean.description = data.description;
                topFirstBean.imgName = data.imgName;
                TopFirstImage image = new TopFirstImage();
                image.large.img = data.imagelist.large.img;
                image.large.width = data.imagelist.large.width;
                image.large.height = data.imagelist.large.height;
                image.medium.img = data.imagelist.medium.img;
                image.medium.width = data.imagelist.medium.width;
                image.medium.height = data.imagelist.medium.height;
                image.small.img = data.imagelist.small.img;
                image.small.width = data.imagelist.small.width;
                image.small.height = data.imagelist.small.height;
                image.tiny.img = data.imagelist.tiny.img;
                image.tiny.width = data.imagelist.tiny.width;
                image.tiny.height = data.imagelist.tiny.height;
                topFirstBean.authorId = data.authorId;
                topFirstBean.authorName = data.authorName;
                topFirstBean.reviewed = data.reviewed;
                topFirstBean.order = data.order;
                topFirstBean.shareCount = data.shareCount;
                topFirstBean.viewCount = data.viewCount;
                topFirstBean.syncOnlineServer = data.syncOnlineServer;
                topFirstBean.syncTestServer = data.syncTestServer;
                topFirstBean.createdAt = data.createdAt;
                topFirstBean.updatedAt = data.updatedAt;
                topFirstBean.formatDate = data.formatDate;
                itemList.add(topFirstBean);
                break;
            case "article":
                ArticleBean articleBean = new ArticleBean();
                articleBean.type = data.type;
                articleBean.id = data.id;
                articleBean.slug = data.slug;
                articleBean.title = data.title;
                articleBean.metaDesc = data.metaDesc;
                articleBean.description = data.description;
                articleBean.imgName = data.imgName;
                TopFirstImage image1 = new TopFirstImage();
                image1.large.img = data.imagelist.large.img;
                image1.large.width = data.imagelist.large.width;
                image1.large.height = data.imagelist.large.height;
                image1.medium.img = data.imagelist.medium.img;
                image1.medium.width = data.imagelist.medium.width;
                image1.medium.height = data.imagelist.medium.height;
                image1.small.img = data.imagelist.small.img;
                image1.small.width = data.imagelist.small.width;
                image1.small.height = data.imagelist.small.height;
                image1.tiny.img = data.imagelist.tiny.img;
                image1.tiny.width = data.imagelist.tiny.width;
                image1.tiny.height = data.imagelist.tiny.height;
                articleBean.authorId = data.authorId;
                articleBean.authorName = data.authorName;
                articleBean.reviewed = data.reviewed;
                articleBean.order = data.order;
                articleBean.shareCount = data.shareCount;
                articleBean.viewCount = data.viewCount;
                articleBean.syncOnlineServer = data.syncOnlineServer;
                articleBean.syncTestServer = data.syncTestServer;
                articleBean.createdAt = data.createdAt;
                articleBean.updatedAt = data.updatedAt;
                articleBean.formatDate = data.formatDate;
                itemList.add(articleBean);
                break;
            case "category":
                CategoryBean categoryBean = new CategoryBean();
                categoryBean.id = data.id;
                categoryBean.type = data.type;
                categoryBean.name = data.name;
                categoryBean.slug = data.slug;
                categoryBean.image = data.image;
                categoryBean.imageSmall = data.imageSmall;
                categoryBean.description = data.description;
                categoryBean.topic_count = data.topic_count;
                categoryBean.parent = data.parent;
                categoryBean.order = data.order;
                categoryBean.createdAt = data.createdAt;
                categoryBean.updatedAt = data.updatedAt;
                itemList.add(categoryBean);
                break;
        }
    }
```
相反，使用方式一，想要转化为 list 的方式则优雅很多
```
    List dataList = new ArrayList(); // 新生成一个列表
    // 将原有不同对象放到列表中，已经是详细的对象。
    dataList.add(data.getHeader());
    dataList.addAll(data.getArticles());
    ...
```
### 2. 对象的清晰和结构清晰

方式二的处理方式所有的属性都在一个对象中，无论是结构和占用内存上，都不占优势。特别是在调试过程中，一大片属性都是空的，需要根据不同的 type 的值，去自己分析这个对象有哪些属性，其他无用属性的扰乱，非常不清晰。

### 3. 顺序调整

方式二最大的有点就是能够应对排序的调整，如果排序调了，可以不用改一行代码就能实现了排序。

针对这一点，我想说的是，不同类型的数据，调换位置的可能性非常小。如果这个不同类型的数据带有调整顺序，完全可以通过添加 order 属性解决。

### 4. 添加新对象不对影响老的接口

这一点上方式二并不占优势。 两种方式添加新的对象都不会影响老的接口。方式一根本不会讲新的字段实例化成为对象。而方式二会将json 示例化为对象，但却没有一点用处，浪费了资源。

## 总结

在几点比较中，只有顺序改变能够带来一点好处。其他方面，数组的组织方式并没有带来任何的方便之处，反而使处理更加麻烦，结构更加混乱。
