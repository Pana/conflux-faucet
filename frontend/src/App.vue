<template>
  <div id="app">
    <el-container style="height: 100%">
      <el-header style="background: #409EFF">
        <el-row class="full-height" type="flex" align="middle" justify="left">
          <el-col :span="6">
            <label class="white-font bold-font">{{ $t("message.title") }}</label>
          </el-col>
          <el-col :offset="6" :span="2">
            <el-switch
              style="display: block"
              v-model="isDev"
              active-color="#13ce66"
              inactive-text="开发模式"
              @change="changeDev"
            >
            </el-switch>
          </el-col>
          <el-col :offset="1" :span="3">
            <el-tooltip effect="light" :content="$t('message.tooltip.networkTooltip')">
              <el-tag>{{ networkText }}</el-tag>
            </el-tooltip>
          </el-col>

          <el-col :span="4" v-if="!accountConnected">
            <el-button class="full-width" round v-on:click="authorize">{{
              $t("message.connect")
            }}</el-button>
          </el-col>
          <el-col :span="4" v-if="accountConnected">
            <el-button class="full-width" type="success" @click="showAccount">
              {{ simplifiedAccount }}<i class="el-icon-check el-icon--right"></i>
            </el-button>
          </el-col>
          <el-col :span="2">
            <el-dropdown @command="handleLangCommand" class="full-width">
              <div class="el-dropdown-link full-width bold-font right-align" style="color: white;">
                {{ locale }}<i class="el-icon-arrow-down el-icon--right"></i>
              </div>
              <el-dropdown-menu slot="dropdown">
                <el-dropdown-item command="zh-CN">中文</el-dropdown-item>
                <el-dropdown-item command="en">en</el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
          </el-col>
        </el-row>
      </el-header>

      <el-main class="main-background">
        <faucet-panel></faucet-panel>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import FaucetPanel from "./components/FaucetPanel.vue";
import { getScanHtml } from "./utils";
// import BatchSender from './components/BatchSender.vue';

export default {
  components: {
    // BatchSender

    FaucetPanel
  },
  name: "App",
  data() {
    return {
      // DEBUG: process.env.NODE_ENV !== 'production'
      isDev: this.$store.state.isDev,
      lang: this.$i18n.locale,
      langList: [
        {
          value: "zh-CN",
          label: "中文"
        },
        {
          value: "en",
          label: "en"
        }
      ]
    };
  },
  computed: {
    account() {
      return this.$store.state.account;
    },
    conflux() {
      return this.$store.state.conflux;
    },
    confluxJS() {
      return this.$store.state.confluxJS;
    },
    sdk() {
      return this.$store.state.sdk;
    },
    cfxBalance() {
      return this.$store.state.cfxBalance;
    },
    networkText() {
      switch (this.conflux?.networkVersion) {
        case "1029":
          return "Conflux Tethys";
        case "1":
          return "Conflux Testnet";
        case undefined:
          return "Portal Not Detected";
      }

      return "networkId: " + this.conflux?.networkVersion;
    },
    networkVersion() {
      return this.conflux?.networkVersion;
    },
    simplifiedAccount() {
      return this.$store.getters.simplifiedAccount;
    },
    accountConnected() {
      return this.$store.state.account !== null;
    },
    // isDev() {
    //   return this.$store.state.isDev;
    // }
    locale() {
      switch(this.$i18n.locale) {
        case 'zh-CN':
          return '中文'
        default:
          return this.$i18n.locale;
      }
    }
  },
  mounted() {
    // executed immediately after page is fully loaded
    this.$nextTick(function() {
      if (typeof window.conflux !== "undefined") {
        this.$store.dispatch("init", {
          conflux: window.conflux,
          confluxJS: window.confluxJS,
          sdk: window.ConfluxJSSDK
        });
      } else {
        this.$alert(
          '前往安装 <a href="https://portal.conflux-chain.org/" target="_blank">ConfluxPortal</a>',
          "未检测到 Conflux Portal",
          {
            dangerouslyUseHTMLString: true,
            showClose: false,
            showCancelButton: false,
            showConfirmButton: false
          }
        );
      }
      if (localStorage.locale) {
        this.$i18n.locale = localStorage.locale
      }
    });
  },
  watch: {
    networkVersion(newVal) {
      if (newVal === undefined) {
        return;
      }
      if (parseInt(window.conflux.networkVersion) !== 1) {
        console.log(this.networkVersion);
        this.$alert(
          this.$t("message.warning.changeNetworkWarning"),
          this.$t("message.error.networkError"),
          {
            showClose: false,
            showCancelButton: false,
            showConfirmButton: false,
            // closeOnClickModal: true,
            // closeOnPressEscape: true,
            callBack: () => {}
          }
        ).catch(() => {
          // 点击框外触发
          // do nothing
        });
      }
    },
    locale(newVal) {
      localStorage.locale = this.$i18n.locale
    }
  },
  methods: {
    handleLangCommand(locale) {
      this.$i18n.locale = locale;
    },
    changeLocale() {
      this.$i18n.locale = this.lang;
    },
    async authorize() {
      try {
        await this.$store.dispatch("authorize");
      } catch (e) {
        this.processError(e);
      }
    },
    processError(err) {
      this.$alert(err.message, his.$t("message.error.error"));
    },
    changeDev() {
      // this.isDev ^= 1
      this.$store.commit("changeDev");
    },
    showAccount() {
      this.$alert(
        this.account +
          "<br>" +
          getScanHtml(
            this.account,
            "address",
            this.networkVersion,
            this.$t("message.toConfluxScan")
          ),
        "当前账户地址",
        {
          showClose: false,
          showCancelButton: false,
          showConfirmButton: false,
          closeOnClickModal: true,
          closeOnPressEscape: true,
          dangerouslyUseHTMLString: true
          // callBack: ()=>{}
        }
      ).catch(() => {
        // 点击框外触发
        // do nothing
      });
    }
  }
};
</script>

<style>
html,
body,
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /* text-align: center; */
  color: #2c3e50;
  /* margin-top: 60px; */
  padding: 0px;
  margin: 0px;
  height: 100%;
}

.main-background {
  /* background: #E4E7ED; */
  background: #ebeef5;
}

.full-height {
  height: 100%;
  /* align: middle; */
}

.full-width {
  width: 100%;
}

.right-align {
  text-align: right;
}

.center-align {
  text-align: center;
}

.bold-font {
  font-weight: bold;
}

.white-font {
  color: white;
}

.el-card {
  margin: 10px;
}

.lang-select {
  background: none;
}
</style>
