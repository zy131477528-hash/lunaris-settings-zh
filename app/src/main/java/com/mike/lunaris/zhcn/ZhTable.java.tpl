package com.mike.lunaris.zhcn;

import java.util.HashMap;
import java.util.Map;

/** 英文原文 -> 简体中文。由 tools/gen_table.py 自动生成，共 __COUNT__ 条。 */
public final class ZhTable {
    private static final Map<String, String> MAP = new HashMap<>(__SIZE__);

    static {
__ENTRIES__
    }

    private ZhTable() {}

    /** 返回译文，没有对应项时返回 null。 */
    public static String get(String en) {
        if (en == null) return null;
        return MAP.get(en);
    }

    public static int size() {
        return MAP.size();
    }
}
