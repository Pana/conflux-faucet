<template>
  <el-card>
    <ul>
      <li>Conflux测试网水龙头每&nbsp;<el-tag type='warning' size=mini>120s</el-tag>&nbsp;可以领取一次，每次可领取&nbsp;<el-tag type=success size=mini>1</el-tag>&nbsp;代币</li>
      <li>使用Conflux测试网水龙头需要安装浏览器插件<el-link href="https://portal.conflux-chain.org/" type="primary" target="_blank">ConfluxPortal<i class="el-icon-top-right el-icon--right"></i></el-link></li>
    </ul>
  </el-card>
</template>
<script>

export default {
  name: "InfoPanel"
};
</script>
<style scoped>
li {
  padding: 10px;
  list-style-type: circle;
}
</style>
