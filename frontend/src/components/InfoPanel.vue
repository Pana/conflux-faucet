<template>
  <el-card>
    <ul>
      <li>{{$t('message.tooltip.faucet.frequency.beg')}}<el-tag type='warning' size=mini>{{faucetInterval}}s</el-tag>{{$t('message.tooltip.faucet.frequency.mid')}}<el-tag type=success size=mini>{{faucetAmount}}</el-tag>{{$t('message.tooltip.faucet.frequency.end')}}</li>
      <li>{{$t('message.tooltip.faucet.portal.beg')}}<el-link href="https://portal.confluxnetwork.org/" type="primary" target="_blank">ConfluxPortal<i class="el-icon-top-right el-icon--right"></i></el-link>{{$t('message.tooltip.faucet.portal.end')}}</li>
    </ul>
  </el-card>
</template>
<script>

export default {
  name: "InfoPanel",
  props: ['faucetAmount', 'faucetInterval']
};
</script>
<style scoped>
li {
  padding: 10px;
  list-style-type: circle;
}
</style>
