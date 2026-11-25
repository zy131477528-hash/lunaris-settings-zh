package com.mike.lunaris.zhcn;

import android.app.Application;
import android.content.Context;
import android.content.res.Resources;

import de.robv.android.xposed.IXposedHookLoadPackage;
import de.robv.android.xposed.XC_MethodHook;
import de.robv.android.xposed.XposedBridge;
import de.robv.android.xposed.XposedHelpers;
import de.robv.android.xposed.callbacks.XC_LoadPackage;

/**
 * Lunaris Settings 简体中文补全
 * 在 com.android.settings 进程内 hook Resources 字符串获取，把英文回退贴回中文。
 * 不修改 APK、不重签、不动系统分区；在 LSPosed 中停用本模块即可恢复。
 */
public class Module implements IXposedHookLoadPackage {

    private static final String TAG = "LunarisZh";
    private static final String TARGET_PKG = "com.android.settings";

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam lpparam) {
        if (!TARGET_PKG.equals(lpparam.packageName)) return;

        XposedBridge.log(TAG + ": loading in " + lpparam.packageName + " (" + lpparam.processName + ")");

        try {
            Class<?> resources = Resources.class;
            // getString(int) / getString(int, Object...)
            XposedHelpers.findAndHookMethod(resources, "getString", int.class, new StringHook());
            XposedHelpers.findAndHookMethod(resources, "getString", int.class, Object[].class, new StringHook());
            XposedHelpers.findAndHookMethod(resources, "getText", int.class, new TextHook());
            XposedBridge.log(TAG + ": hooks installed");
        } catch (Throwable t) {
            XposedBridge.log(TAG + ": hook failed: " + t);
        }
    }

    private static class StringHook extends XC_MethodHook {
        @Override
        protected void afterHookedMethod(MethodHookParam param) {
            Object r = param.getResult();
            if (r instanceof String) {
                String translated = ZhTable.get((String) r);
                if (translated != null) param.setResult(translated);
            }
        }
    }

    private static class TextHook extends XC_MethodHook {
        @Override
        protected void afterHookedMethod(MethodHookParam param) {
            Object r = param.getResult();
            if (r == null) return;
            String s = r.toString();
            String translated = ZhTable.get(s);
            if (translated != null) {
                param.setResult(new android.text.SpannedString(translated));
            }
        }
    }
}
